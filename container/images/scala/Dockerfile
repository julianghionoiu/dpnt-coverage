ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

# Install sbt
## Not downloading a fixed version but expecting debian to give us one
RUN apt-get install apt-transport-https curl gnupg -yqq
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
RUN chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
RUN apt-get update && apt-get install sbt

# Precache dependencies for faster run - will populate the IVY cache
ENV SBT_BUILD_TMP /tmp/sbt
RUN mkdir -p ${SBT_BUILD_TMP} && \
    git clone --depth 1 https://github.com/io-accelerate/tdl-runner-scala.git ${SBT_BUILD_TMP}
RUN ( cd ${SBT_BUILD_TMP} && sbt --debug update )

RUN sbt --version