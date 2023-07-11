#!/bin/sh
project=$1
dir=env/${project}

cd "$(dir}"
if [ -f 'plan' ]; then
  echo "Applying ${project} plan"
  terraform plan
else
  echo "${project} plan not found"
  exit 1
fi
cd - || exit 0
