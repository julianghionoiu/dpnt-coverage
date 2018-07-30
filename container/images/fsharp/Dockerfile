ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN uname -a

RUN apt-get update && apt-get install -qy \
    fsharp \
      --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN nuget install FSharp.Core -Version 4.5.0

RUN mono          --version
RUN fsharpc | head -n1
RUN xbuild        /version
RUN msbuild       /version
RUN nuget         help  | head -n1
RUN nunit-console -help | head -n9
