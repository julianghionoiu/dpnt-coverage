# Java code coverage

Scripts for retrieving code coverage for `java` related `tdl-runner` projects:

- `Dockerfile` contains definition of the image to build and copies `fetch_repo_and_collect_coverage.sh` into the `/home/ubuntu` directory. The `buildDockerImage.sh` script builds the needed base docker image. It takes two parameters i.e. image name and image version, which by default are set (see script for default values).
- `runDockerContainer.sh` checks if it can find the required image or else calls `buildDockerImage.sh`, then loads and run the docker image.
- `fetch_repo_and_collect_coverage.sh` clones the repo inside the docker container, see usage. 

Usage `fetch_repo_and_collect_coverage.sh`:

Takes in 4 parameters:
    - working dir i.e. /home/ubuntu/
	- repo url i.e.  https://github.com/julianghionoiu/tdl-runner-java.git    
	- tag name i.e. xxx-2.0
	- challengeId i.e. HLO
