#!/bin/bash

list_versions() {
  repository="$1"

  token=$(curl -s "https://ghcr.io/token?scope=repository:$repository:pull" | jq -r '.token')
  versions=$(curl -s -H "Authorization: Bearer $token" "https://ghcr.io/v2/$repository/tags/list" | jq -r '.tags')
  echo "$versions"
}

# Get latest version of intel-ucode
intel_ucode_version=0
version_array=($(list_versions "siderolabs/intel-ucode" | jq -r '.[]'))
for element in "${version_array[@]}"; do
  if [[ "$element" =~ ^[0-9]+$ && "$element" -gt "$intel_ucode_version" ]]; then
    intel_ucode_version="$element"
  fi
done

if [[ "$intel_ucode_version" -eq 0 ]]; then
  echo "Unable to find the latest version for siderolabs/intel-ucode."
  exit 1
fi

# echo "The latest version of siderolabs/intel-ucode is: $intel_ucode_version"

# Get latest version of qemu-guest-agent
qemu_ga_version=""
version_array=($(list_versions "siderolabs/qemu-guest-agent" | jq -r '.[]'))
largest_major=0
largest_minor=0
largest_patch=0

# Loop through the bash array and find the largest version
for version in "${version_array[@]}"; do
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    major="${version%%.*}"
    minor="${version#*.}"
    minor="${minor%%.*}"
    patch="${version##*.}"

    if [[ "$major" -gt "$largest_major" || ("$major" -eq "$largest_major" && "$minor" -gt "$largest_minor") || ("$major" -eq "$largest_major" && "$minor" -eq "$largest_minor" && "$patch" -gt "$largest_patch") ]]; then
      largest_major="$major"
      largest_minor="$minor"
      largest_patch="$patch"
      qemu_ga_version="$version"
    fi
  fi
done

if [[ -z "$qemu_ga_version" ]]; then
  echo "Unable to find the latest version for siderolabs/qemu-guest-agent."
  exit 1
fi

# echo "The latest version of siderolabs/qemu-guest-agent is: $qemu_ga_version"

jq -n --arg intel_ucode_version "$intel_ucode_version" --arg qemu_ga_version "$qemu_ga_version" '{"intel_ucode_version":$intel_ucode_version, "qemu_ga_version":$qemu_ga_version}'
