ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

# Precache dependencies for faster run - will populate the Maven cache
RUN mkdir -p /tmp/gradle/wrapper
ARG KOTLIN_RUNNER_REPO=https://raw.githubusercontent.com/julianghionoiu/tdl-runner-kotlin/master
ADD ${KOTLIN_RUNNER_REPO}/gradle/wrapper/gradle-wrapper.properties /tmp/gradle/wrapper/gradle-wrapper.properties
ADD ${KOTLIN_RUNNER_REPO}/gradle/wrapper/gradle-wrapper.jar /tmp/gradle/wrapper/gradle-wrapper.jar
ADD ${KOTLIN_RUNNER_REPO}/gradlew /tmp/gradlew
ADD ${KOTLIN_RUNNER_REPO}/build.gradle.kts /tmp/build.gradle.kts
RUN chmod a+x /tmp/gradlew

WORKDIR /tmp
RUN ./gradlew --version
RUN ./gradlew dependencies
WORKDIR ${WORKDIR}