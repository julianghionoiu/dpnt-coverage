#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "dotnet" "master" "SUM" "100"
computeCoverageForChallenge "dotnet" "master" "TST" "50"
computeCoverageForChallenge "dotnet" "master" "CHK" "0"
computeCoverageForChallenge "dotnet" "master" "xyz" "0"

displayPassFailSummary
