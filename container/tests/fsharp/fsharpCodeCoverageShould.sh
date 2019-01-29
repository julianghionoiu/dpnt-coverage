#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "fsharp" "master" "SUM" "100"
computeCoverageForChallenge "fsharp" "master" "TST" "50"
computeCoverageForChallenge "fsharp" "master" "CHK" "0"

checkForFailingCoverageResults "fsharp" "master" "xyz" ""

displayPassFailSummary
