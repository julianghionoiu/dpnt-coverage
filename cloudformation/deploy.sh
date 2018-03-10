################################################################################
# 
################################################################################
aws \
    --region $DPTN_COVERAGE_AWS_REGION \
    --profile $DPTN_COVERAGE_AWS_PROFILE \
     cloudformation \
        create-stack \
            --stack-name dpnt-coverage \
            --template-body file://definition.yml \
             --capabilities CAPABILITY_IAM
