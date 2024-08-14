#!/bin/bash

JARS_DIR="./jars"
mkdir -p $JARS_DIR

download_jar() {
    local url=$1
    local filename=$(basename $url)
    echo "Downloading $filename..."
    curl -L $url -o "$JARS_DIR/$filename"
}

# AWS Glue Iceberg connector
download_jar "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.3.1/iceberg-aws-bundle-1.3.1.jar"

# AWS SDK bundle
download_jar "https://repo1.maven.org/maven2/software/amazon/awssdk/aws-sdk-java/2.20.18/aws-sdk-java-2.20.18.jar"

# Iceberg Spark runtime
download_jar "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.3_2.12/1.3.1/iceberg-spark-runtime-3.3_2.12-1.3.1.jar"

# Spark SQL AWS bundle
download_jar "https://repo1.maven.org/maven2/org/apache/spark/spark-sql-aws_2.12/3.3.2/spark-sql-aws_2.12-3.3.2.jar"

# AWS Java SDK bundle
download_jar "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.1026/aws-java-sdk-bundle-1.11.1026.jar"

echo "All JARs downloaded successfully."