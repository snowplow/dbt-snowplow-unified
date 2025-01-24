#!/bin/bash

# Create a new spark-defaults.conf with substituted values
sed -e "s|\${AWS_ACCESS_KEY_ID}|$AWS_ACCESS_KEY_ID|g" \
    -e "s|\${AWS_SECRET_ACCESS_KEY}|$AWS_SECRET_ACCESS_KEY|g" \
    -e "s|\${AWS_REGION}|$AWS_REGION|g" \
    -e "s|\${S3_BUCKET}|$S3_BUCKET|g" \
    -e "s|\${S3_RAW_DATA_DIR}|$S3_RAW_DATA_DIR|g" \
    -e "s|\${S3_DWH_DIR}|$S3_DWH_DIR|g" \
    /spark/conf/spark-defaults.conf.template > /spark/conf/spark-defaults.conf

# Execute the passed command
exec "$@"