#!/bin/bash

# Get all task definitions containing "uat"
task_definitions=$(aws ecs list-task-definitions --region us-east-2 --output json | jq -r '.taskDefinitionArns[] | select(contains("uat-usea2"))')

# Extract unique families and their latest versions
declare -A latest_versions
for arn in $task_definitions; do
  family=$(echo "$arn" | awk -F: '{sub(/:[0-9]+$/, "", $0); print $0}')
  version=$(echo "$arn" | awk -F: '{print $NF}')
  if [[ -z "${latest_versions[$family]}" || "${latest_versions[$family]}" -lt "$version" ]]; then
    latest_versions[$family]=$version
  fi
done

# Print the latest version for each family
for family in "${!latest_versions[@]}"; do
  echo "$family:${latest_versions[$family]}"
done