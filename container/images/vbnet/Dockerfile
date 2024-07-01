ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

RUN uname -a

RUN apt-get update && apt-get install -qy \
    libmono-system-design4.0-cil          \
    libmono-cecil-vb0.9-cil               \
    libmono-microsoft-visualbasic10.0-cil \
    mono-vbnc                             \
    mono-runtime                          \
    mono-mcs                              \
    xmlstarlet                            \
      --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN mono          --version
RUN vbnc          2>&1 | head -n1
RUN vbc           2>&1 | head -n1
RUN xbuild        /version
RUN msbuild       /version
RUN nuget         help  2>&1 | head -n1
RUN nunit-console -help  2>&1 | head -n9
