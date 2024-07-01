#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "python" "main" "SUM" "100"
computeCoverageForChallenge "python" "main" "TST" "50"
computeCoverageForChallenge "python" "main" "CHK" "0"

checkForFailingCoverageResults "python" "main" "xyz" ""

displayPassFailSummary
