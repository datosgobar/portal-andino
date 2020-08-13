#!/usr/bin/env bash

set -ev

container_id=$(docker ps -q --filter "name=_portal_")
echo Container id: $container_id
container_image=$(docker ps --format '{{ .Image }}' --filter "id=$container_id")
echo Container image name: $container_image
tag="$1"

image_full_name="datosgobar/portal-andino:$tag"
echo $DOCKER_PASS | docker login -u="$DOCKER_USERNAME" --password-stdin
docker tag "$container_image" "$image_full_name"
echo "Deploying image $image_full_name"
docker push "$image_full_name"
echo "Deploy finished!"
exit 0
