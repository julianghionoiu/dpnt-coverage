# Scala code coverage

Scripts for retrieving code coverage for `scala` related `tdl-runner` projects:

- `Dockerfile` contains definition of the image to build and copies `fetch_repo_and_collect_coverage.sh` into the `/home/ubuntu` directory. Expects following environment variables to be available `REPO`, `TAG` and `CHALLENGE_ID`. 
- The `buildDockerImage.sh` script builds the needed base docker image. It takes two parameters i.e. image name and image version, which by default are set (see script for default values).
- `runDockerContainer.sh` checks if it can find the required image or else calls `buildDockerImage.sh`, then loads and run the docker image.
- `fetch_repo_and_collect_coverage.sh` clones the repo inside the docker container, see usage. 

Usage `fetch_repo_and_collect_coverage.sh`:

Takes in 3 parameters:
	- repo url i.e.  https://github.com/julianghionoiu/tdl-runner-scala.git    
	- tag name i.e. xxx-2.0
	- challengeId i.e. HLO

Example:
    
    ```
       cd containers/scala
       ./fetch_repo_and_collect_coverage.sh https://github.com/julianghionoiu/tdl-runner-java.git xxx-2.0 HLO         
    ```	
