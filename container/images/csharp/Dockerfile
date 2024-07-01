ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

RUN uname -a

RUN apt-get update && apt-get install -qy \
    gtk-sharp2 \
        --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN mono          --version
RUN mcs           --version
RUN xbuild        /version
RUN msbuild       /version
RUN nuget         help  2>&1 | head -n1
RUN nunit-console -help  2>&1 | head -n9
