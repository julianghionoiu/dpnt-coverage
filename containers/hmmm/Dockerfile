FROM java:8u111-jdk

RUN touch /usr/lib/jvm/java-1.8.0-openjdk-amd64/release
RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

RUN apt-get update -q
RUN apt-get install -qy python-pip groff-base
RUN pip install awscli

ENV WORK_DIR /srv/workdir
RUN mkdir -p ${WORK_DIR}
WORKDIR ${WORK_DIR}

ENV SRCS_VERSION 0.0.12
RUN wget https://github.com/julianghionoiu/dev-sourcecode-record/releases/download/v${SRCS_VERSION}/dev-sourcecode-record-${SRCS_VERSION}-all.jar \
    -O ${WORK_DIR}/dev-sourcecode-record-all.jar

ADD ./fetch_repo_and_collect_coverage.sh ${WORK_DIR}/fetch_repo_and_collect_coverage.sh

ENTRYPOINT ${WORK_DIR}/fetch_repo_and_collect_coverage.sh
