#!/usr/bin/env bash

set -e
set -o pipefail

source ../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "java" "master" "SUM" "100"
computeCoverageForChallenge "java" "master" "CHK" "0"

displayPassFailSummary