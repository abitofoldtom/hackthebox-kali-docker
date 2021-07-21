#!/bin/bash

IMAGE_NAME=kustom_kali

CONFIG_FILE=$1
RUNNING_CONTAINER=$(docker ps | grep kustom_kali | awk '{print $1}')

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "$CONFIG_FILE does not exist"
  exit 1
fi

if [[ "${CONFIG_FILE: -5}" != ".ovpn" ]]; then
  echo "$CONFIG_FILE is not an .ovpn config file"
  exit 1
fi

if [[ $RUNNING_CONTAINER ]]; then
  echo "stopping $IMAGE_NAME container $RUNNING_CONTAINER..."
  docker stop $RUNNING_CONTAINER >/dev/null 2>/dev/null
fi

EXISTING_IMAGE=$(docker images | grep $IMAGE_NAME | tr -s ' ' | cut -d ' ' -f 3)

if [[ $EXISTING_IMAGE ]]; then
  echo "removing $IMAGE_NAME image $EXISTING_IMAGE..."
  docker rmi --force $EXISTING_IMAGE >/dev/null 2>/dev/null
fi

echo "using openvpn config $CONFIG_FILE..."

echo "buildling $IMAGE_NAME image..."

docker build --build-arg CONFIG_FILE=$CONFIG_FILE -t $IMAGE_NAME . >/dev/null 2>/dev/null

echo "running new $IMAGE_NAME container..."

NEW_CONTAINER=$(docker run -d --rm \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  $IMAGE_NAME)

echo "$NEW_CONTAINER running..."

echo "starting interactive session..."

docker exec -it $NEW_CONTAINER bash

echo "stopping container $NEW_CONTAINER..."

docker stop $NEW_CONTAINER >/dev/null 2>/dev/null

RUNNING_CONTAINER=$(docker ps | grep kustom_kali | awk '{print $1}')

if [[ $RUNNING_CONTAINER ]]; then
  echo "unable to stop $IMAGE_NAME container $RUNNING_CONTAINER..."
else
  echo "stopped $IMAGE_NAME container $RUNNING_CONTAINER"

