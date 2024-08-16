#!/bin/bash

echo "Starting network diagnostics..."
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I)"
echo "Pinging spark-master..."
ping -c 4 spark-master

echo "Starting Spark service..."
exec "$@"