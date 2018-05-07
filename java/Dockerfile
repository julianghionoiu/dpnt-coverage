FROM java:8u111-jdk

RUN apt-get update && apt-get install -y \
				gradle \
                git \
        --no-install-recommends && rm -r /var/lib/apt/lists/*