
# The coverage container

Use the scripts provided to create the language specific containers.

The build follows a multi-stage process:
1. Build the base image `./base`
2. Build the language specific image `./LANGUAGE_ID`

In order to run this in one go, you can use:
```
./buildDockerImage.sh <language_id>
```

## Versioning

Each folder, including `base` contains a `version.txt` file.
This file should be incremented when the version changes.

The `base` image version is injected into the language specific images via the use of ARG in Dockerfile.

The `latest` tag has a special meaning and it is used by the ECS local simulator to match the Docker container to be run.

## Running

In a nutshell the container operate in 3 steps:
1. Get the target REPO
2. Compute coverage
3. Publish coverage

Step `1.` can work with either public Github repos or S3 SRCS files.
When working with S3 files, appropriate AWS S3 ENV variables should be provided.
Step `3.` can publish to console (`echo`) or to an SQS queue. If AWS SQS ENV variables are populated, SQS will be used.


## Manual Testing

The containers can be tested against public Git repos.
Example:
```
./runDockerContainer.sh hmmm participant round https://github.com/julianghionoiu/tdl-runner-hmmm TCH_R1/done TCH

# should display "coverage=33"
```
Running in this way will cover everything except reading from S3 and publishing to SQS.


## Automated Testing

By running the `local-ecs` and then the Acceptance test, one will cover the:
- passing AWS ENV variables into container
- reading SRCS from S3
- exporting SRCS files to local folders
- publishing coverage data to SQS

This testing does not cover language specific support. That should be covered by the container tests.


## Debugging container

Once the container is stop the logs can be viewed with:
```
docker logs <container_id>
```

To be able to interactively log into the container and debug the state or even run further commands manually we have the follow command:

```
    DEBUG=true ./runDockerContainer.sh [rest of the args]

For e.g.
    DEBUG=true ./runDockerContainer.sh hmmm participant round https://github.com/julianghionoiu/tdl-runner-hmmm TCH_R1/done TCH
```

Inside the container under `/debug-repo/` you can place any repo or file or folders - volume sharing between host and container environments.

In case a repo is placed there, and would like to pass it to the `fetch_repo_and_collect_coverage.sh` command:
```
./fetch_repo_and_collect_coverage.sh hmmm participant round ../debug-repo/prod-issue/ master CHK
                                                            ^^^^^^^ git repo (should have the .git folder)
``` 
In case the folder does not have a .git folder, create one by running `git init` inside that folder. 

# Deploying to ECR

```
./deployToECR.sh kotlin 577770582757.dkr.ecr.eu-west-1.amazonaws.com
```
