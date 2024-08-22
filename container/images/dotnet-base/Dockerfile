ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

RUN uname -a

RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb &&\
    dpkg -i packages-microsoft-prod.deb &&\
    rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -qy \
    dotnet-sdk-8.0 \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN dotnet --version
