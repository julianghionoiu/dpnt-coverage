FROM java:8u111-jdk

ENV USER_IN_CONTAINER ubuntu
ENV HOME_DIR /home/ubuntu

RUN touch /usr/lib/jvm/java-1.8.0-openjdk-amd64/release
RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

RUN apt-get update && apt-get install -y \
		              gradle \
                              git \
                              libxml2-utils \
        --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash $USER_IN_CONTAINER
USER $USER_IN_CONTAINER

RUN echo "export PATH=$JAVA_HOME/bin:$PATH" >> $HOME_DIR/.bashrc

WORKDIR $HOME_DIR

ADD ./fetch_repo_and_collect_coverage.sh $HOME_DIR/fetch_repo_and_collect_coverage.sh

ENTRYPOINT $HOME_DIR/fetch_repo_and_collect_coverage.sh ${REPO} ${TAG} ${CHALLENGE_ID}
