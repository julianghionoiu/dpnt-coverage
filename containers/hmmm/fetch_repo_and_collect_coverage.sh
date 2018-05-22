#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

LOCAL_REPO_DESTINATION="./tdl-runner"
LOCAL_SRCS_FILE="./file.srcs"

# To check if an ENV variable exists, we dereference the input string $1 -> !1
# then then we attempt parameter expansion with the "+x" string
# it should return an empty string if ENV not defined
# Reference: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
function ensure_env {
    if [ -z "${!1+x}" ]; then echo "Environment variable $1 not set"; exit 1; fi
}

ensure_env "S3_ENDPOINT"
ensure_env "S3_REGION"

ensure_env "SQS_ENDPOINT"
ensure_env "SQS_REGION"
ensure_env "SQS_QUEUE_URL"

ensure_env "REPO"
ensure_env "TAG"
ensure_env "CHALLENGE_ID"


# Clone and switch to TAG
if [[ "${REPO}" == s3://* ]];
then
    echo "S3 based SRCS file detected"
    aws s3  --endpoint-url ${S3_ENDPOINT} \
            --region ${S3_REGION} \
            --no-verify-ssl \
            cp ${REPO} ${LOCAL_SRCS_FILE}

else
    echo "Assuming Git repo"
    git clone ${REPO} ${LOCAL_REPO_DESTINATION}
    cd ${LOCAL_REPO_DESTINATION}
    git checkout ${TAG}
    git pull origin ${TAG}
fi


# Run the coverage
echo  "~~~~~~ START run external script ~~~~~~" > /dev/null
./get_coverage_for_challenge.sh ${CHALLENGE_ID}
echo "~~~~~~ STOP run external script ~~~~~~" > /dev/null

# Publish to Queue