#!/bin/bash

MAX_RETRIES=30
RETRY_INTERVAL=5
IP_REGEX='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'


for ((i = 1; i <= MAX_RETRIES; i++)); do
  address=$(arp-scan --localnet | grep "$1" | awk ' { printf $1 } ')
  
  if [[ -n "$address" && "$address" =~ $IP_REGEX ]]; then
    jq -n --arg address "$address" '{"address":$address}'
    exit 0
  fi
  
  if [ $i -lt $MAX_RETRIES ]; then
    sleep $RETRY_INTERVAL
  else
    echo "Maximum retries reached. Address not found."
    exit 1
  fi
done