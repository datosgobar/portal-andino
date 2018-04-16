#!/bin/bash

set -e;

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TAG="$1"
ENVIRONMENTS="$2"

"$DIR/upload.sh" "$TAG"

if [ -n "$ENVIRONMENTS" ]; then
    IFS=';'
    for env in  "${ENVIRONMENTS[@]}"; do
        echo "Corriendo Continuous Deployment en $env";
        "$DIR/deploy/run_deploy.sh" "$env"
    done
else
    echo "Sin ambientes para Continuous Deployment"
fi
