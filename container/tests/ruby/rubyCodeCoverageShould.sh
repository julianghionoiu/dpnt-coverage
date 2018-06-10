#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "ruby" "master" "SUM" "100"
computeCoverageForChallenge "ruby" "master" "TST" "83"
computeCoverageForChallenge "ruby" "master" "CHK" "0"
computeCoverageForChallenge "ruby" "master" "xyz" "0"

displayPassFailSummary
