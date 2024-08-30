#!/bin/bash

# Set variables
DOCKER_HUB_ORG="snowplow"
IMAGE_NAME="spark-s3-iceberg"
TAG="latest"

# Build the image
echo "Building Docker image..."
docker build --platform linux/amd64 -t $DOCKER_HUB_ORG/$IMAGE_NAME:$TAG .

# Log in to Docker Hub
echo "Logging in to Docker Hub..."
docker login

# Push the image to Docker Hub
echo "Pushing image to Docker Hub..."
docker push $DOCKER_HUB_ORG/$IMAGE_NAME:$TAG

echo "Image successfully built and pushed to Docker Hub"