ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN uname -a

RUN apt-get update && apt-get install -qy \
    libmono-system-design4.0-cil          \
    libmono-cecil-vb0.9-cil               \
    libmono-microsoft-visualbasic10.0-cil \
    mono-vbnc                             \
    mono-runtime                          \
    mono-mcs                              \
      --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN mono          --version
RUN vbnc          | head -n1
RUN vbc           | head -n1
RUN xbuild        /version
RUN msbuild       /version
RUN nuget         help  | head -n1
RUN nunit-console -help | head -n9
