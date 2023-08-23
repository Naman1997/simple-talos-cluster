#!/bin/bash

list_versions() {
  repository="$1"
  token=$(curl -s "https://ghcr.io/token?scope=repository:$repository:pull" | jq -r '.token')
  last_version=""
  all_versions=()

  while true; do
    response=$(curl -s -H "Authorization: Bearer $token" "https://ghcr.io/v2/$repository/tags/list?n=1000&last=$last_version")
    tags=$(echo "$response" | jq -r '.tags')
    if [ "$tags" == "null" ]; then
      break
    fi

    readarray -t versions < <(echo "$response" | jq -c '.tags[]' | sed 's/"//g')
    for version in "${versions[@]}"; do
      all_versions+=("$version")
      last_version="$version"
    done
  done

  for version in "${all_versions[@]}"; do
    echo "$version"
  done
}

# Get latest version of intel-ucode
intel_ucode_version=0
for element in $(list_versions "siderolabs/intel-ucode"); do
  if [[ "$element" =~ ^[0-9]+$ && "$element" -gt "$intel_ucode_version" ]]; then
    intel_ucode_version="$element"
  fi
done

if [[ "$intel_ucode_version" -eq 0 ]]; then
  echo "Unable to find the latest version for siderolabs/intel-ucode."
  exit 1
fi

# echo "The latest version of siderolabs/intel-ucode is: $intel_ucode_version"

# Get latest version of amd-ucode
amd_ucode_version=0
for element in $(list_versions "siderolabs/amd-ucode"); do
  if [[ "$element" =~ ^[0-9]+$ && "$element" -gt "$amd_ucode_version" ]]; then
    amd_ucode_version="$element"
  fi
done

if [[ "$amd_ucode_version" -eq 0 ]]; then
  echo "Unable to find the latest version for siderolabs/amd-ucode."
  exit 1
fi

# echo "The latest version of siderolabs/intel-ucode is: $amd_ucode_version"

# Get latest version of qemu-guest-agent
qemu_ga_version=""
largest_major=0
largest_minor=0
largest_patch=0

# Loop through the bash array and find the largest version
for version in $(list_versions "siderolabs/qemu-guest-agent"); do
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

imager_version=""
for version in $(list_versions "siderolabs/imager"); do
  if [[ $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    imager_version="$version"
  fi
done

if [[ -z "$imager_version" ]]; then
  echo "Unable to find the latest version for siderolabs/imager."
  exit 1
fi

# echo "The latest version of siderolabs/imager is: $imager_version"

jq -n --arg intel_ucode_version "$intel_ucode_version"\
 --arg amd_ucode_version "$amd_ucode_version" \
 --arg qemu_ga_version "$qemu_ga_version" \
 --arg imager_version "$imager_version" \
 '{"intel_ucode_version":$intel_ucode_version, "amd_ucode_version":$amd_ucode_version, "qemu_ga_version":$qemu_ga_version, "imager_version":$imager_version}'

# jq -n --arg intel_ucode_version "$intel_ucode_version"\
#  --arg amd_ucode_version "$amd_ucode_version" \
#  --arg qemu_ga_version "$qemu_ga_version" \
#  '{"intel_ucode_version":$intel_ucode_version, "amd_ucode_version":$amd_ucode_version, "qemu_ga_version":$qemu_ga_version, "imager_version": "v1.5.0"}'
