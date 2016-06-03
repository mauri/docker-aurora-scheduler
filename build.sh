#! /bin/bash
set -eux

AURORA_IMAGE_VERSION="v2.0.0-"
AURORA_SNAPSHOT="https://github.com/medallia/aurora/archive/rel/0.13.0-medallia.tar.gz"
AURORA_RELEASE="0.13.0-medallia"
AURORA_PACKAGE_BRANCH="master"

AURORA_IMAGE="aurora-scheduler:${AURORA_IMAGE_VERSION}${AURORA_RELEASE}"

echo "AURORA-PACKAGING-BRANCH ${AURORA_PACKAGE_BRANCH}"
echo "RELEASE ${AURORA_RELEASE}"
echo "SNAPSHOT ${AURORA_SNAPSHOT}"
echo "DOCKER IMAGE ${AURORA_IMAGE}"

BASE_DIR="$(pwd)"

# fetch source
curl -L -o "snap.tar.gz" "$AURORA_SNAPSHOT"
if [ ! -d aurora-packaging ]; then
    git clone "https://github.com/apache/aurora-packaging.git" "aurora-packaging"
fi

(cd aurora-packaging && \
 git fetch origin "$AURORA_PACKAGE_BRANCH" && \
 git checkout "$AURORA_PACKAGE_BRANCH" && \
 ./build-artifact.sh builder/deb/ubuntu-trusty \
        "${BASE_DIR}/snap.tar.gz" \
        "$AURORA_RELEASE" && \
 cp -a "artifacts/aurora-ubuntu-trusty/dist/aurora-scheduler_${AURORA_RELEASE}_amd64.deb" "${BASE_DIR}")

docker build --build-arg "AURORA_RELEASE=${AURORA_RELEASE}" -t "docker.m8s.io/medallia/${AURORA_IMAGE}" .
