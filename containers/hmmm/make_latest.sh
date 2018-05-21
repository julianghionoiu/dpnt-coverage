#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

dockerImageName=${1:-accelerate-io/dpnt-coverage-hmmm}
docker tag ${dockerImageName}:0.1 ${dockerImageName}:latest
