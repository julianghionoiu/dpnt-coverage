#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "nodejs" "master" "SUM" "100"
computeCoverageForChallenge "nodejs" "master" "TST" "75"
computeCoverageForChallenge "nodejs" "master" "CHK" "0"
computeCoverageForChallenge "nodejs" "master" "xyz" "0"

displayPassFailSummary
