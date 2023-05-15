ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Precache dependencies for faster run - will populate the Maven cache
RUN mkdir -p /tmp/gradle/wrapper
ARG JAVA_RUNNER_REPO=https://raw.githubusercontent.com/julianghionoiu/tdl-runner-java/master
ADD ${JAVA_RUNNER_REPO}/gradle/wrapper/gradle-wrapper.properties /tmp/gradle/wrapper/gradle-wrapper.properties
ADD ${JAVA_RUNNER_REPO}/gradle/wrapper/gradle-wrapper.jar /tmp/gradle/wrapper/gradle-wrapper.jar
ADD ${JAVA_RUNNER_REPO}/gradlew /tmp/gradlew
ADD ${JAVA_RUNNER_REPO}/build.gradle /tmp/build.gradle
RUN chmod a+x /tmp/gradlew

WORKDIR /tmp
RUN ./gradlew --version
RUN ./gradlew dependencies
WORKDIR ${WORKDIR}