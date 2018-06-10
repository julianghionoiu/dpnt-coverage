ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV SCALA_VERSION 2.12.3
ENV SBT_VERSION 0.13.8
# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get install sbt && \
  sbt sbtVersion

# Precache dependencies for faster run - will populate the IVY cache
ENV SBT_BUILD_TMP /tmp/sbt
RUN mkdir -p ${SBT_BUILD_TMP} && \
    git clone --depth 1 https://github.com/julianghionoiu/tdl-runner-scala.git ${SBT_BUILD_TMP}
RUN ( cd ${SBT_BUILD_TMP} && sbt --debug update )