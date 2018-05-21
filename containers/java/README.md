# Java code coverage

Scripts for retrieving code coverage for `java` related `tdl-runner` projects:

- `fetch_repo_and_collect_coverage.sh` clones the repo inside the docker container. 
- `Dockerfile` contains definition of the image to build and copies `fetch_repo_and_collect_coverage.sh` into the `/home/ubuntu` directory. 
- The `buildDockerImage.sh` script builds the needed base docker image. It takes two parameters i.e. image name and image version, which by default are set (see script for default values).
- `runDockerContainer.sh` checks if it can find the required image or else calls `buildDockerImage.sh`, then loads and run the docker image, see usage.

Usage `runDockerContainer.sh`:

Takes in 3 parameters:
	- repo url i.e.  https://github.com/julianghionoiu/tdl-runner-java.git    
	- tag name i.e. xxx-2.0
	- challengeId i.e. HLO

Example:
    
    ```
       cd containers/java 
       ./runDockerContainer.sh https://github.com/julianghionoiu/tdl-runner-java.git xxx-2.0 HLO         
    ```	
