#!/bin/bash

# === CONFIG ===
IMAGE_NAME="prakashlearner13/myfirstdockerimage:latest"
CONTAINER_NAME="myhtmlapp"
CHECK_INTERVAL=60   # seconds between checks

echo "🔄 Auto-deploy script started for $IMAGE_NAME"
echo "Checking every $CHECK_INTERVAL seconds..."

# Get initial digest
CURRENT_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE_NAME 2>/dev/null)

while true; do
  sleep $CHECK_INTERVAL

  # Pull the latest image silently
  docker pull $IMAGE_NAME > /dev/null 2>&1

  # Get new digest
  NEW_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE_NAME 2>/dev/null)

  # If digests differ → redeploy
  if [ "$CURRENT_DIGEST" != "$NEW_DIGEST" ]; then
    echo "🚀 New version detected! Redeploying..."
    docker stop $CONTAINER_NAME >/dev/null 2>&1
    docker rm $CONTAINER_NAME >/dev/null 2>&1
    docker run -d --name $CONTAINER_NAME -p 8080:80 $IMAGE_NAME
    CURRENT_DIGEST=$NEW_DIGEST
    echo "✅ Updated and running latest image at http://localhost:8080"
  else
    echo "🟢 No change detected. Still running latest."
  fi
done
