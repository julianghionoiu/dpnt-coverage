#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "kotlin" "master" "SUM" "100"
computeCoverageForChallenge "kotlin" "master" "TST" "50"
computeCoverageForChallenge "kotlin" "master" "CHK" "0"

checkForFailingCoverageResults "kotlin" "master" "xyz" ""

displayPassFailSummary
