#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function die() { echo >&2 $1; exit 1; }
[ "$#" -eq 1 ] || die "Usage: $0 LANGUAGE_ID"
LANGUAGE_ID=$1

echo "Compute language specific name+version"
DEFAULT_IMAGE_PREFIX="accelerate-io/dpnt-coverage-"
language_image_version=$( cat "${SCRIPT_CURRENT_DIR}/${LANGUAGE_ID}/version.txt" | tr -d " " | tr -d "\n" )
language_image_name="${DEFAULT_IMAGE_PREFIX}${LANGUAGE_ID}"
language_image_tag="${language_image_name}:${language_image_version}"

echo "Make the current image the latest"
docker tag ${language_image_tag} ${language_image_name}:latest