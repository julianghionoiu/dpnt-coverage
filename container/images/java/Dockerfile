ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -qy \
    maven \
    gradle \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

# Precache dependencies for faster run - will populate the Maven cache
RUN wget https://raw.githubusercontent.com/julianghionoiu/tdl-runner-java/master/build.gradle \
    -O /tmp/build.gradle && \
    gradle --build-file /tmp/build.gradle dependencies

RUN echo "JAVA_HOME=${JAVA_HOME}"
RUN echo "PATH=${PATH}"
RUN java -version