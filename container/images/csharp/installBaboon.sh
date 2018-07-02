#!/usr/bin/env bash

set -e
set -u
set -o pipefail

apt-get update && \
   apt-get -qy install sqlite3 libsqlite3-dev

# Get the covem tool
git clone https://github.com/inorton/XR.Baboon
cd XR.Baboon
git checkout e1b65b24677293559e5919234929cfa74ff9d766

# Compile
msbuild ./covtool/covtool.csproj

# Assembly should have been generated
ls ./covtool/bin/covem.exe