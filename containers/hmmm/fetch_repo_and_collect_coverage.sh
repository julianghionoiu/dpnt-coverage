#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# To check if an ENV variable exists, we dereference the input string $1 -> !1
# then then we attempt parameter expansion with the "+x" string
# it should return an empty string if ENV not defined
# Reference: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
function ensure_env {
    if [ -z "${!1+x}" ]; then echo "Environment variable $1 not set"; exit 1; fi
}

ensure_env "WORK_DIR"

ensure_env "S3_ENDPOINT"
ensure_env "S3_REGION"

ensure_env "SQS_ENDPOINT"
ensure_env "SQS_REGION"
ensure_env "SQS_QUEUE_URL"

ensure_env "REPO"
ensure_env "TAG"
ensure_env "CHALLENGE_ID"

# Configure local files
LOCAL_REPO_DESTINATION="${WORK_DIR}/tdl-runner"
LOCAL_SRCS_FILE="${WORK_DIR}/file.srcs"


# Clone and switch to TAG
if [[ "${REPO}" == s3://* ]];
then
    echo "S3 based SRCS file detected"
    aws s3  --endpoint-url ${S3_ENDPOINT} \
            --region ${S3_REGION} \
            --no-verify-ssl \
            cp ${REPO} ${LOCAL_SRCS_FILE}
    java -jar ${WORK_DIR}/dev-sourcecode-record-all.jar export \
        --input ${LOCAL_SRCS_FILE} \
        --output ${LOCAL_REPO_DESTINATION} \
        --tag ${TAG}

else
    echo "Assuming Git repo"
    git clone ${REPO} ${LOCAL_REPO_DESTINATION}
    git --git-dir ${LOCAL_REPO_DESTINATION} checkout ${TAG}
    git --git-dir ${LOCAL_REPO_DESTINATION} pull origin ${TAG}
fi


# Run the coverage
COVERAGE_SCRIPT="${LOCAL_REPO_DESTINATION}/get_coverage_for_challenge.sh"
chmod a+x ${COVERAGE_SCRIPT}
echo  "~~~~~~ START run external script ~~~~~~" > /dev/null
${COVERAGE_SCRIPT} ${CHALLENGE_ID}
echo "~~~~~~ STOP run external script ~~~~~~" > /dev/null

# Publish to Queue