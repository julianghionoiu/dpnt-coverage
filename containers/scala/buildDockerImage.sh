#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dockerImageName=${1:-accelerate-io/dpnt-coverage-scala}
dockerImageVersion=${2:-0.1}

echo "Building docker image for with the name ${dockerImageName}:${dockerImageVersion}"
docker build -t ${dockerImageName}:${dockerImageVersion} ${SCRIPT_CURRENT_DIR}/.

echo "Remove any dangling images from the local registry"
docker images -q -f dangling=true | xargs docker rmi -f  || true
