#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function die() { echo >&2 $1; exit 1; }
[ "$#" -eq 1 ] || die "Usage: $0 STAGE"
STAGE=$1

STACK_NAME="dpnt-coverage-ecs-cluster-${STAGE}"
STACK_REGION="eu-west-1"
BUILD_DIR="${SCRIPT_CURRENT_DIR}/.build"
TEMPLATE_FILE="${BUILD_DIR}/cloudformation-template-ecs-cluster.json"
PARAMETERS_FILE="${SCRIPT_CURRENT_DIR}/../config/${STAGE}.ecstask.json"

echo "Compile cloudformation template" > /dev/null
python ${SCRIPT_CURRENT_DIR}/compile_cf_template.py ${TEMPLATE_FILE}

echo "Sanity check the template" > /dev/null
aws cloudformation validate-template \
    --template-body "file://${TEMPLATE_FILE}"

echo "Ensure stack exists" > /dev/null
if ! aws cloudformation describe-stacks --stack-name ${STACK_NAME} > /dev/null 2>&1; then
    echo "Stack does not exists. Creating..."
    aws cloudformation create-stack \
        --stack-name ${STACK_NAME} \
        --region ${STACK_REGION} \
        --template-body  "{ \"Resources\": { \"stack-${STACK_NAME}\": { \"Type\": \"AWS::S3::Bucket\" }}}"
fi

echo "Update stack" > /dev/null
aws cloudformation update-stack \
    --stack-name ${STACK_NAME} \
    --region ${STACK_REGION} \
    --template-body "file://${TEMPLATE_FILE}" \
    --parameters "file://${PARAMETERS_FILE}" \
    --capabilities CAPABILITY_NAMED_IAM



echo "Wait for stack to complete the update" > /dev/null
aws cloudformation wait stack-update-complete \
    --stack-name ${STACK_NAME}
if [ $? -gt 0 ]; then
     aws cloudformation describe-stack-events \
        --stack-name ${STACK_NAME} \
        --max-items 10 | jq '.StackEvents[] | { "type": .ResourceType, "status":.ResourceStatus, "reason":.ResourceStatusReason}'
fi