#! /bin/bash
set -eux

AURORA_IMAGE_VERSION="v2.1.0"
AURORA_RELEASE="0.13.0-medallia-2"
AURORA_SNAPSHOT="https://github.com/medallia/aurora/archive/rel/${AURORA_RELEASE}.tar.gz"
AURORA_PACKAGE_BRANCH="master"

AURORA_IMAGE="aurora-scheduler:${AURORA_IMAGE_VERSION}-${AURORA_RELEASE}"

echo "AURORA-PACKAGING-BRANCH ${AURORA_PACKAGE_BRANCH}"
echo "RELEASE ${AURORA_RELEASE}"
echo "SNAPSHOT ${AURORA_SNAPSHOT}"
echo "DOCKER IMAGE ${AURORA_IMAGE}"

BASE_DIR="$(pwd)"

if [ ! -f aurora-scheduler_${AURORA_RELEASE}_amd64.deb ]; then
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
fi

if [ -z ${GITHUB_TOKEN} ]; then
  echo "Missing GITHUB_TOKEN environment variable"
  exit 1
fi

UPLOAD_URL=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/medallia/aurora/releases/tags/rel/${AURORA_RELEASE} | grep upload_url | awk '{print $2}' | awk -F'{' '{sub(/\"/, "", $1); print $1}' )

if [ -z ${UPLOAD_URL} ]; then
  echo "Could not find release with name ${AURORA_RELEASE}"
  echo "Check release or credentials"
  exit 1
fi


if [ ! -f aurora-scheduler_${AURORA_RELEASE}_amd64.deb ]; then
  echo "Cannot find package aurora-scheduler_${AURORA_RELEASE}_amd64.deb"
  exit 1
fi
STATUS=""
echo "Uploading aurora-scheduler_${AURORA_RELEASE}_amd64.deb to github"
UPLOAD_URL="${UPLOAD_URL}?name=aurora-scheduler_${AURORA_RELEASE}_amd64_test.deb"
RES=$(curl -# -XPOST -H "Authorization:token ${GITHUB_TOKEN}" -H "Content-Type:application/octet-stream" --data-binary @aurora-scheduler_${AURORA_RELEASE}_amd64.deb ${UPLOAD_URL})
if [[ -z $(echo "$RES" | grep -o "\"state\":\"[a-z]*") ]]; then
  echo "Upload failed"
  echo "Is the package already uploaded ? Delete first"
  echo "$RES" | grep -o 'message\":\"[A-Za-z ]*'\"
  exit 1
fi

echo "Building Docker Image"

docker build --build-arg "AURORA_RELEASE=${AURORA_RELEASE}" -t "medallia/${AURORA_IMAGE}" .
