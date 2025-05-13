#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Network name (must match the one used in docker-compose.yml)
NETWORK_NAME="hadoop_spark_net"

# --- Source Node Tier Configuration ---
CONFIG_FILE="node_tiers.env"
if [[ -f "$CONFIG_FILE" ]]; then
    echo "Loading node tier configuration from $CONFIG_FILE..."
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file '$CONFIG_FILE' not found."
    echo "Please create it with MASTER_HOSTNAME_CONFIG, HIGH_PERF_HOSTNAMES, MID_PERF_HOSTNAMES, and LOW_PERF_HOSTNAMES definitions."
    exit 1
fi

# Validate that variables are loaded
: "${MASTER_HOSTNAME_CONFIG:?ERROR: MASTER_HOSTNAME_CONFIG not set in $CONFIG_FILE. Please define it.}"
: "${HIGH_PERF_HOSTNAMES:?ERROR: HIGH_PERF_HOSTNAMES not set in $CONFIG_FILE. Please define it as an array (e.g., HIGH_PERF_HOSTNAMES=(\"host1\" \"host2\")).}"
: "${MID_PERF_HOSTNAMES:?ERROR: MID_PERF_HOSTNAMES not set in $CONFIG_FILE. Please define it as an array.}"
: "${LOW_PERF_HOSTNAMES:?ERROR: LOW_PERF_HOSTNAMES not set in $CONFIG_FILE. Please define it as an array.}"


echo "Starting Docker Swarm setup script..."
echo "-------------------------------------"

# --- Create Overlay Network ---
echo ""
echo "Step 1: Ensuring overlay network '$NETWORK_NAME' exists..."
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Network '$NETWORK_NAME' not found. Creating..."
    docker network create -d overlay --attachable "$NETWORK_NAME"
    echo "Network '$NETWORK_NAME' created successfully."
else
    echo "Network '$NETWORK_NAME' already exists."
fi
echo "-------------------------------------"

# --- Node Labeling ---
echo ""
echo "Step 2: Applying labels to Swarm nodes..."

# Get all nodes: ID, Hostname, ManagerStatus (Leader or empty)
docker node ls --format "{{.ID}} {{.Hostname}} {{.ManagerStatus}}" | while read -r NODE_ID NODE_HOSTNAME MANAGER_STATUS; do
    echo "Processing Node -> ID: $NODE_ID, Hostname: $NODE_HOSTNAME, ManagerStatus: ${MANAGER_STATUS:-Worker}"

    # Determine if this node is the designated master or the current Swarm Leader
    IS_MASTER_NODE=false
    if [[ "$NODE_HOSTNAME" == "$MASTER_HOSTNAME_CONFIG" ]] || [[ "$MANAGER_STATUS" == "Leader" ]]; then
        IS_MASTER_NODE=true
    fi

    if $IS_MASTER_NODE; then
        echo "  Applying labels for MASTER node ($NODE_HOSTNAME)..."
        docker node update --label-add spark-role=master "$NODE_ID"
        # Note: 'h-role=master' is not typically used if 'node.role == manager' constraint is used for namenode.
        # docker node update --label-add h-role=master "$NODE_ID"
        echo "    Added: spark-role=master"
    else
        echo "  Applying labels for WORKER node ($NODE_HOSTNAME)..."
        docker node update --label-add h-role=worker "$NODE_ID"
        docker node update --label-add spark-role=worker "$NODE_ID"
        echo "    Added: h-role=worker, spark-role=worker"

        # Performance tier labeling based on hostname lists
        PERFORMANCE_LABEL=""

        # Check High Performance List
        for hostname_in_list in "${HIGH_PERF_HOSTNAMES[@]}"; do
            if [[ "$hostname_in_list" == "$NODE_HOSTNAME" ]]; then
                PERFORMANCE_LABEL="performance=high"
                break
            fi
        done

        # Check Mid Performance List (only if not already found)
        if [[ -z "$PERFORMANCE_LABEL" ]]; then
            for hostname_in_list in "${MID_PERF_HOSTNAMES[@]}"; do
                if [[ "$hostname_in_list" == "$NODE_HOSTNAME" ]]; then
                    PERFORMANCE_LABEL="performance=mid"
                    break
                fi
            done
        fi

        # Check Low Performance List (only if not already found)
        if [[ -z "$PERFORMANCE_LABEL" ]]; then
            for hostname_in_list in "${LOW_PERF_HOSTNAMES[@]}"; do
                if [[ "$hostname_in_list" == "$NODE_HOSTNAME" ]]; then
                    PERFORMANCE_LABEL="performance=low"
                    break
                fi
            done
        fi

        if [[ -n "$PERFORMANCE_LABEL" ]]; then
            docker node update --label-add "$PERFORMANCE_LABEL" "$NODE_ID"
            echo "    Added: $PERFORMANCE_LABEL"
        else
            echo "    No specific performance tier defined for hostname '$NODE_HOSTNAME'."
        fi
    fi
    echo "  -------------------"
done

echo ""
echo "Node labeling complete."
echo "-------------------------------------"
echo "Script finished."
echo "Review the node labels using 'docker node inspect <node_id_or_hostname>' or 'docker node ls'."
