#! /bin/bash
set -eux

if [ $# -eq 0 ]; do
	echo "Usage: build.sh <aurora-release-name> <snapshot-tar-gz-url>"
fi;

AURORA_SNAPSHOT="https://github.com/medallia/aurora/archive/0.11.0-medallia.tar.gz"
AURORA_RELEASE="0.11.0-medallia"
AURORA_PACKAGE_BRANCH="$(echo $AURORA_RELEASE | head -c 5)x"

AURORA_IMAGE="aurora-scheduler:${AURORA_RELEASE}"

echo "AURORA-PACKAGING-BRANCH ${AURORA_PACKAGE_BRANCH}"
echo "RELEASE ${AURORA_RELEASE}"
echo "SNAPSHOT ${AURORA_SNAPSHOT}"
echo "DOCKER IMAGE ${AURORA_IMAGE}"

BASE_DIR="$(pwd)"

# fetch source
wget -O "snap.tar.gz" "$AURORA_SNAPSHOT"
git clone "https://github.com/apache/aurora-packaging.git" "aurora-packaging"

(cd aurora-packaging && \
 git fetch origin "$AURORA_PACKAGE_BRANCH" && \
 git checkout "$AURORA_PACKAGE_BRANCH" && \
 ./build-artifact.sh builder/deb/ubuntu-trusty \
        "${BASE_DIR}/snap.tar.gz" \
        "$AURORA_RELEASE" && \
 cp -a "artifacts/aurora-ubuntu-trusty/dist/aurora-scheduler_${AURORA_RELEASE}_amd64.deb" "${BASE_DIR}")

docker build --build-arg "AURORA_RELEASE=${AURORA_RELEASE}" -t "${AURORA_IMAGE}" .
