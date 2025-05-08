import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

def main():
    # HDFS path for the directory containing CSV files
    # Spark will read all CSV files within this directory
    hdfs_directory_path = "hdfs://namenode:9000/test_bd/ibm_card_txn/" 
    
    print(f"Attempting to read all CSV files from {hdfs_directory_path} with Spark...")

    # Initialize a SparkSession
    spark = SparkSession.builder.appName("HDFSGroupedCountExample").getOrCreate()

    spark.sparkContext.setLogLevel("ERROR")  # Set log level to ERROR to reduce verbosity

    try:
        # Load all CSV data from the directory into a DataFrame
        # Spark automatically reads all CSV files in hdfs_directory_path
        df = spark.read.csv(hdfs_directory_path, header=True, inferSchema=True)
        
        print("\nSchema of the combined DataFrame:")
        df.printSchema()
        
        print(f"\nTotal rows loaded from {hdfs_directory_path}: {df.count()}")

        # Perform groupBy and count
        print("\nPerforming groupBy('Merchant City').count()...")
        
        if "Merchant City" in df.columns:
            merchant_counts_df = df.groupBy("Merchant City").count()
            
            print("\nCounts by Merchant City:")
            merchant_counts_df.show(truncate=False)
        else:
            print(f"Error: Column 'Merchant City' not found in the DataFrame.")
            print(f"Available columns: {df.columns}")

    except Exception as e:
        print(f"An error occurred during Spark processing: {e}")
    finally:
        # Stop the SparkSession
        spark.stop()
        print("\nSpark session stopped.")

if __name__ == "__main__":
    main()