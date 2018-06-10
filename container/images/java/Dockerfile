ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -qy \
    maven \
    gradle \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

# Precache dependencies for faster run - will populate the Maven cache
RUN wget https://raw.githubusercontent.com/julianghionoiu/tdl-runner-java/master/pom.xml \
    -O /tmp/pom.precache && \
    mvn dependency:resolve --file /tmp/pom.precache