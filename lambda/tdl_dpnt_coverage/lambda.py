"""
Lambda handler to receive SNS event and then run ECS RunTask
"""

import json
import boto
import os

CLOUDFORMATION_TEMPLATE_URL=os.environ.get('CLOUDFORMATION_TEMPLATE_URL')

def generate_coverage(event, context):
    body = {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response

    # Use this code if you don't use the http event with the LAMBDA-PROXY
    # integration
    """
    return {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
    """

def deploy_coverage_runner():
    client = boto3.client('cloudformation')
    stack_name = 'Coverage_Runner_' + 'blablabla'
    client.create_stack(
        StackName=stack_name,
        TemplateUrl=CLOUDFORMATION_TEMPLATE_URL
    )
