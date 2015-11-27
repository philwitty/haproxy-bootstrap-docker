#!/bin/sh
set -e

DOCKER=`sh /etc/profile; which docker`

DOCKER_REGISTRY="docker-registry.expend.io"
IMAGE_NAME="haproxy-bootstrap-docker"

IMAGE_TAG=${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
"${DOCKER}" build -t ${IMAGE_TAG} .
echo "..docker build ${IMAGE_TAG} completed"

if [ "$DRONE_BRANCH" = "master" ] && [ "$DRONE_PULL_REQUEST" = "" ]; then
    "${DOCKER}" push ${IMAGE_TAG}
    echo "..docker push ${IMAGE_TAG} completed"
fi

# Cleanup docker images to avoid space leakage
"${DOCKER}" rmi $(docker images | grep "^${DOCKER_REGISTRY}/${IMAGE_NAME}" | awk '{print $3}')
images=$("${DOCKER}" images -f "dangling=true" -q)
if [ $images ]; then
    "${DOCKER}" rmi $images
fi
