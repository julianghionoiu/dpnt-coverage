FROM java:8u111-jdk

RUN apt-get update && apt-get install -y \
		                      gradle \
                              git \
        --no-install-recommends && rm -r /var/lib/apt/lists/*

ADD fetch_repo_and_collect_coverage.sh ${WORKING_DIR}

ENTRYPOINT fetch_repo_and_collect_coverage.sh ${WORKING_DIR} ${REPO} ${TAG} ${CHALLENGE_ID}