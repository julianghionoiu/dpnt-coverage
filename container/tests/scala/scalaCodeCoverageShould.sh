#!/usr/bin/env bash

set -e
set -o pipefail

source ../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "scala" "master" "SUM" "100"
computeCoverageForChallenge "scala" "master" "CHK" "0"

displayPassFailSummary