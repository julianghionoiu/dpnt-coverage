FROM java:8u111-jdk

ADD ./fetch_repo_and_collect_coverage.sh $HOME_DIR/fetch_repo_and_collect_coverage.sh

ENTRYPOINT $HOME_DIR/fetch_repo_and_collect_coverage.sh ${REPO} ${TAG} ${CHALLENGE_ID}
