#!/usr/bin/env bash

set -ev

tag_or_branch="$1";

container_id=$(docker-compose -f dev.yml ps -q portal)
container_image=$(docker ps --format '{{ .Image }}' --filter "id=$container_id")
tag_or_branch="$TRAVIS_BRANCH"

# 0.0.1, 1.2.33,1.2.33-beta1 are valid patterns
# a0.0.1, 0.0a.1, 0.0.1a, 0.0 are not valid patterns
pattern="^[0-9]+.[0-9]+.[0-9]+"

if [ "$tag_or_branch" == "master" ]; then
    tag="latest"
elif [[ "$tag_or_branch" =~ $pattern ]]; then
    tag="release-$tag_or_branch"
else
    tag="$tag_or_branch"
fi

image_full_name="datosgobar/portal-andino:$tag"
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASS";
docker tag "$container_image" "$image_full_name"
echo "Deploying image $image_full_name"
docker push "$image_full_name"
echo "Deploy finished!"
exit 0
