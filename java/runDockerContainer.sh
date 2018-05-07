#!/usr/bin/env bash

set -e
set -u
set -o pipefail

repo=$1
tag=$2	
challengeId=$3

dockerImageName="accelerate-io/tdl-runner-java"
dockerImageVersion="v01"
WORKING_DIR="/home/ubuntu/"

docker run                                                                      \
      --rm                                                                      \
      --interactive                                                             \
      --volume ${PWD}/getLineCoverageFor.sh:/home/ubuntu/getLineCoverageFor.sh  \
      --workdir=${WORKING_DIR}                                                  \
      ${dockerImageName}:${dockerImageVersion}                                  \
        ./getLineCoverageFor.sh ${WORKING_DIR} ${repo} ${tag} ${challengeId}
