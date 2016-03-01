#! /bin/bash
set -eux

AURORA_PACKAGE_BRANCH="0.11.x"
AURORA_SNAPSHOT="https://github.com/medallia/aurora/archive/0.11.0-medallia.tar.gz"
AURORA_RELEASE="0.11.0-medallia"

BASE_DIR="$(pwd)"

# fetch source
wget -O "snap.tar.gz" "$AURORA_SNAPSHOT"
git clone "https://github.com/mauri/aurora-packaging.git" "aurora-packaging"

(cd aurora-packaging && \
 git fetch origin "$AURORA_PACKAGE_BRANCH" && \
 git checkout "$AURORA_PACKAGE_BRANCH" && \
 ./build-artifact.sh builder/deb/ubuntu-trusty \
        "${BASE_DIR}/snap.tar.gz" \
        "$AURORA_RELEASE" && \
 cp -a "artifacts/aurora-ubuntu-trusty/dist/aurora-scheduler_${AURORA_RELEASE}_amd64.deb" "${BASE_DIR}/aurora.deb")

docker build -t "aurora-scheduler:${AURORA_RELEASE}" .


