ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN uname -a

RUN ln -s /usr/lib/apt/methods/http /usr/lib/apt/methods/https
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-get update && apt-get -y install apt-transport-https curl
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-jessie main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN apt-get update && apt-get install -qy \
    mono-devel \
    mono-complete \
    nunit-console

RUN wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
RUN mkdir -p /usr/lib/nuget/
RUN cp nuget.exe                    /usr/lib/nuget/
RUN ln -sf /usr/lib/nuget/nuget.exe /usr/bin/nuget 

RUN mono                          --version
RUN mcs                           --version
RUN xbuild                        /version
RUN msbuild                       /version
RUN mono /usr/lib/nuget/nuget.exe -version
RUN nunit-console                 -help | head -n9
RUN mono /usr/bin/nuget           help  | head -n1