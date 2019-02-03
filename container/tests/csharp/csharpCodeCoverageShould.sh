#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "csharp" "master" "SUM" "100"
computeCoverageForChallenge "csharp" "master" "TST" "50"
computeCoverageForChallenge "csharp" "master" "CHK" "0"

checkForFailingCoverageResults "csharp" "master" "xyz" ""

displayPassFailSummary
