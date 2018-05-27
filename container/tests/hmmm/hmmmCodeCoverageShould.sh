#!/usr/bin/env bash

set -e
set -o pipefail

source ../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "hmmm" "TCH_R1/done" "SUM" "33"
computeCoverageForChallenge "hmmm" "TCH_R2/done" "SUM" "44"

displayPassFailSummary
