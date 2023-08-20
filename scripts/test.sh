#!/bin/bash

repository="siderolabs/imager"
token=$(curl -s "https://ghcr.io/token?scope=repository:$repository:pull" | jq -r '.token')

all_versions=()
last_version=""

while true; do
  response=$(curl -s -H "Authorization: Bearer $token" "https://ghcr.io/v2/$repository/tags/list?n=10&last=$last_version")
  versions=$(echo "$response" | jq -r '.tags[]')

  if [ -z "$versions" ]; then
    break
  fi

  all_versions+=("$versions")
  last_version="${versions[${#versions[@]} - 1]}"
  echo ""
  echo "Last version: $last_version"
done
