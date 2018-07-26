#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="${SCRIPT_CURRENT_DIR}/images"
DEFAULT_IMAGE_PREFIX="accelerate-io/dpnt-coverage-"

BASE="base"
LANGUAGE_ID=$1
case ${LANGUAGE_ID} in
    csharp|fsharp|vbnet)
    BASE="dotnet" ;;
esac

BASE_IMAGE_VERSION=$( cat "${IMAGES_DIR}/${BASE}/version.txt" | tr -d " " | tr -d "\n" )
ROOT_BASE_IMAGE_TAG="${DEFAULT_IMAGE_PREFIX}base:${BASE_IMAGE_VERSION}"
DOTNET_BASE_IMAGE_TAG="${DEFAULT_IMAGE_PREFIX}dotnet:${BASE_IMAGE_VERSION}"
BASE_IMAGE_TAG=${ROOT_BASE_IMAGE_TAG}

function die() { echo >&2 $1; exit 1; }
[ "$#" -eq 1 ] || die "Usage: $0 LANGUAGE_ID"

echo "~~~~~~ Refreshing base image ~~~~~~"
if [[ "${BASE}" == "base"  ]]; then
    docker build -t ${BASE_IMAGE_TAG} "${IMAGES_DIR}/${BASE}/."
elif [[ "${BASE}" == "dotnet"  ]]; then
    BASE_IMAGE_TAG=${DOTNET_BASE_IMAGE_TAG}
    docker build -t ${BASE_IMAGE_TAG} "${IMAGES_DIR}/${BASE}/." --build-arg BASE_IMAGE="${ROOT_BASE_IMAGE_TAG}"
fi

echo "Compute language specific name+version"
language_image_version=$( cat "${SCRIPT_CURRENT_DIR}/images/${LANGUAGE_ID}/version.txt" | tr -d " " | tr -d "\n" )
language_image_name="${DEFAULT_IMAGE_PREFIX}${LANGUAGE_ID}"
language_image_tag="${language_image_name}:${language_image_version}"

echo "~~~~~~ Building language specific image ~~~~~~"
docker build -t ${language_image_tag} --build-arg BASE_IMAGE="${BASE_IMAGE_TAG}" \
    "${IMAGES_DIR}/${LANGUAGE_ID}/."

echo "Make the current image the latest"
docker tag ${language_image_tag} ${language_image_name}:latest
