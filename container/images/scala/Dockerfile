ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

ENV SCALA_VERSION 2.12.8

# Install Scala
## Installing openjdk-8-jdk to prevent the jre-headless or jdk-headless errors from occurring
RUN apt-get --fix-broken install
RUN apt-get update && apt-get install -qy openjdk-11-jdk

RUN wget www.scala-lang.org/files/archive/scala-$SCALA_VERSION.deb
RUN dpkg -i scala-$SCALA_VERSION.deb
RUN scala -version

# Install sbt
## Not downloading a fixed version but expecting debian to give us one
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
RUN apt-get install apt-transport-https
RUN apt-get update && apt-get install sbt

# Precache dependencies for faster run - will populate the IVY cache
ENV SBT_BUILD_TMP /tmp/sbt
RUN mkdir -p ${SBT_BUILD_TMP} && \
    git clone --depth 1 https://github.com/julianghionoiu/tdl-runner-scala.git ${SBT_BUILD_TMP}
RUN ( cd ${SBT_BUILD_TMP} && sbt --debug update )

RUN scala -version
RUN sbt sbtVersion