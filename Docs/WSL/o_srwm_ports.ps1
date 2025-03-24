# Open-FirewallPorts.ps1
# This script opens specific firewall ports by creating new inbound rules.
# Required ports:
#   - TCP port 2377
#   - TCP port 7946
#   - UDP port 7946
#   - UDP port 4789
#   - TCP port 22 (for SSH)

# Define an array of firewall rule definitions
$firewallRules = @(
    @{DisplayName = "Open TCP port 2377"; Protocol = "TCP"; LocalPort = 2377 },
    @{DisplayName = "Open TCP port 7946"; Protocol = "TCP"; LocalPort = 7946 },
    @{DisplayName = "Open UDP port 7946"; Protocol = "UDP"; LocalPort = 7946 },
    @{DisplayName = "Open UDP port 4789"; Protocol = "UDP"; LocalPort = 4789 },
    @{DisplayName = "Open TCP port 22 for SSH"; Protocol = "TCP"; LocalPort = 22 },
    @{DisplayName = "Open TCP port 7077 for Spark"; Protocol = "TCP"; LocalPort = 7077 }
)

# Loop through each rule and create it if it doesn't exist already
foreach ($rule in $firewallRules) {
    $existingRule = Get-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue
    if (-not $existingRule) {
        Write-Output "Creating firewall rule: $($rule.DisplayName)"
        New-NetFirewallRule -DisplayName $rule.DisplayName `
                            -Direction Inbound `
                            -Action Allow `
                            -Protocol $rule.Protocol `
                            -LocalPort $rule.LocalPort `
                            -Profile Domain,Private,Public
    } else {
        Write-Output "Firewall rule '$($rule.DisplayName)' already exists."
    }
}

Write-Output "Firewall rules have been configured."
