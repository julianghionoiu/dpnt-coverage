FROM java:8u111-jdk

ENV SCALA_VERSION 2.12.3
ENV SBT_VERSION 0.13.8
ENV HOME_DIR /home/ubuntu/

RUN touch /usr/lib/jvm/java-1.8.0-openjdk-amd64/release

RUN apt-get update && apt-get install -y \
		              gradle \
                              git \
                              libxml2-utils \
        --no-install-recommends && rm -r /var/lib/apt/lists/*

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /home/ubuntu/ && \
  echo >> $HOME_DIR/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> $HOME_DIR/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

RUN echo "export PATH=$JAVA_HOME/bin:$PATH" >> $HOME_DIR/.bashrc

USER ubuntu

WORKDIR $HOME_DIR
ADD ./fetch_repo_and_collect_coverage.sh $HOME_DIR/fetch_repo_and_collect_coverage.sh

ENTRYPOINT $HOME_DIR/fetch_repo_and_collect_coverage.sh ${REPO} ${TAG} ${CHALLENGE_ID}
