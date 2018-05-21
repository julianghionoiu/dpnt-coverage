FROM java:8u111-jdk

RUN apt-get update -q
RUN apt-get install -qy python-pip groff-base
RUN pip install awscli

ENV HOME_DIR /home/ubuntu

ADD ./fetch_repo_and_collect_coverage.sh $HOME_DIR/fetch_repo_and_collect_coverage.sh

ENTRYPOINT $HOME_DIR/fetch_repo_and_collect_coverage.sh
