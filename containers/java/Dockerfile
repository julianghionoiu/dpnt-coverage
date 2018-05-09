FROM java:8u111-jdk

RUN apt-get update && apt-get install -y \
		                      gradle \
                              git \
        --no-install-recommends && rm -r /var/lib/apt/lists/*

WORKDIR /home/ubuntu/
ADD ./fetch_repo_and_collect_coverage.sh /home/ubuntu/fetch_repo_and_collect_coverage.sh

ENTRYPOINT /home/ubuntu/fetch_repo_and_collect_coverage.sh ${REPO} ${TAG} ${CHALLENGE_ID}