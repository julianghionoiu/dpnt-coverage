ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

RUN uname -a

RUN apt-key adv --no-tty --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-get update && apt-get -y install apt-transport-https curl
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN apt-get update && apt-get install -qy \
    mono-devel     \
    mono-complete  \
    mono-profiler  \
    nunit-console  \
      --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
RUN mkdir -p /usr/lib/nuget/
RUN cp nuget.exe /usr/lib/nuget/
RUN echo '#!/bin/bash\n mono /usr/lib/nuget/nuget.exe "$@"' > /usr/bin/nuget && \
    chmod +x /usr/bin/nuget

RUN mono          --version
RUN xbuild        /version
RUN msbuild       /version
RUN nuget         help  2>&1 | head -n1
RUN nunit-console -help  2>&1 | head -n9
