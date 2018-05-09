#!/usr/bin/env bash

set -e
set -u
set -o pipefail

WORKING_DIR=$1
REPO=$2
TAG=$3	
CHALLENGE_ID=$4

dockerImageName="accelerate-io/tdl-runner-java"
dockerImageVersion="v01"
WORKING_DIR="/home/ubuntu/"

echo "Checking for the presence of ${dockerImageName}":"${dockerImageVersion} in the local docker registry"
foundDockerImage=$(docker images --filter="reference=${dockerImageName}" | grep "${dockerImageName}" || true)
if [[ -z ${foundDockerImage} ]]; then
  ./docker/buildDockerImage.sh "${dockerImageName}" "${dockerImageVersion}"

  if [[ $? -ne 0 ]]; then
    echo "There was a problem building the docker image needed to run this task, process exited with error code '$?'"
    exit -1
  fi
fi

echo "Running ${dockerImageName}":"${dockerImageVersion} from the local docker registry"
docker run                                                                      \
      --rm                                                                      \
      --interactive                                                             \
      --workdir=${WORKING_DIR}                                                  \
      -env WORKING_DIR=${WORKING_DIR}                                           \
      -env REPO=${REPO}                                                         \
      -env TAG=${TAG}                                                           \
      -env CHALLENGE_ID=${CHALLENGE_ID}                                         \
      ${dockerImageName}:${dockerImageVersion}
        
