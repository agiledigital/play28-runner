#!/bin/bash

location="$1"

echo "Checking [$location] for artifact."

if [[ $location == *s3://* ]]; then
  echo "Downloading artifact from S3 [$location]."

  aws s3 sync --delete "$location" /home/runner/artifacts

  cd /home/runner/artifacts

  # Grab the first file that is a zip file, we assume only 1 zip file as artifact.
  artifactzip="$(ls *.tar.gz | sort | tail -n1)"

  if [ -f "$artifactzip" ]; then
    echo "Found artifact zip file [$artifactzip], unpacking..."
    tar xvzf "$artifactzip"
  else
    echo "No artifact zip file found, resumming with assumption that artifacts are in place."
  fi
else
  echo "Not a S3 location, resumming with assumption that artifacts are in place."
fi
