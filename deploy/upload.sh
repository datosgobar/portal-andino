#!/usr/bin/env bash

set -ev

container_id=$(docker-compose -f dev.yml ps -q portal)
container_image=$(docker ps --format '{{ .Image }}' --filter "id=$container_id")
branch="$TRAVIS_BRANCH"
pattern="^[0-9.]+"

if [ "$branch" == "master" ]; then
    tag="latest"
elif [[ "$branch" =~ $pattern ]]; then
    tag="release-$branch"
else
    tag="$branch"
fi

image_full_name="datosgobar/portal-andino:$tag"
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASS";
docker tag "$container_image" "$image_full_name"
echo "Deploying image $image_full_name"
docker push "$image_full_name"
echo "Deploy finished!"
exit 0
