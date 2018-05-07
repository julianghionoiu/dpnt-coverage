#!/usr/bin/env bash

set -e
set -u
set -o pipefail

repo=$1
tag=$2	
challengeId=$3

dockerImageName="accelerate-io/tdl-runner-java"
dockerImageVersion="v01"

docker run                                                                      \
      --rm                                                                      \
      --interactive                                                             \
      --volume ${PWD}/getLineCoverageFor.sh:/home/ubuntu/getLineCoverageFor.sh  \
      --workdir=/home/ubuntu/                                                   \
      ${dockerImageName}:${dockerImageVersion}                                  \
        ./getLineCoverageFor.sh ${repo} ${tag} ${challengeId}
		
		