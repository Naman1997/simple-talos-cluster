#!/bin/bash
IMAGE_NAME=imager
MAX_RETRIES=30
RETRY_INTERVAL=5

for ((i = 1; i <= MAX_RETRIES; i++)); do
  container_count=$(docker ps --filter "NAME=$IMAGE_NAME" | grep $IMAGE_NAME | wc -l)
  if [[ "$container_count" -eq 0 ]]; then
    sleep 5
    exit 0
  fi
  
  if [ $i -lt $MAX_RETRIES ]; then
    sleep $RETRY_INTERVAL
  else
    echo "Maximum retries reached. Address not found."
    exit 1
  fi
done