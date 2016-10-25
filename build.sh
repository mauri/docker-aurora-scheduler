#! /bin/bash
set -eux

AURORA_IMAGE_VERSION="v2.2.0"
AURORA_VERSION="0.13.0"
AURORA_RELEASE="${AURORA_VERSION}-medallia-2"
AURORA_SNAPSHOT="https://github.com/medallia/aurora/archive/rel/${AURORA_RELEASE}.tar.gz"
AURORA_PACKAGE_BRANCH="0.13.x"

AURORA_IMAGE="aurora-scheduler:${AURORA_IMAGE_VERSION}-${AURORA_RELEASE}"

echo "AURORA-PACKAGING-BRANCH ${AURORA_PACKAGE_BRANCH}"
echo "RELEASE ${AURORA_RELEASE}"
echo "SNAPSHOT ${AURORA_SNAPSHOT}"
echo "DOCKER IMAGE ${AURORA_IMAGE}"

BASE_DIR="$(pwd)"
BUILD_PACKAGE=${BUILD_PACKAGE:-1}

function upload {
  if [ ! -f $1 ]; then
    echo "Cannot find package $1"
    exit 1
  fi
  STATUS=""
  echo "Uploading $1 to github"
  UPLOAD_URL="${UPLOAD_URL}?name=$1" 
  RES=$(curl -# -XPOST -H "Authorization:token ${GITHUB_TOKEN}" -H "Content-Type:application/octet-stream" --data-binary @$1 ${UPLOAD_URL})
  if [[ -z $(echo "$RES" | grep -o "\"state\":\"[a-z]*") ]]; then
    echo "Upload failed"
    echo "Is the package already uploaded ? Delete first"
    echo "$RES" | grep -o 'message\":\"[A-Za-z ]*'\"
    exit 1
  fi
}

if [ $BUILD_PACKAGE -eq 1 ]; then
  # fetch source
  curl -L -o "snap.tar.gz" "$AURORA_SNAPSHOT"

  # XXX: Without this aurora-packaging fails for .rpms since it expects 
  # something of the form apache-aurora-xxx
  tar -xvzf snap.tar.gz 
  mv aurora-rel-$AURORA_VERSION-medallia apache-aurora-$AURORA_VERSION
  tar -czvf snap.tar.gz apache-aurora-$AURORA_VERSION 
  rm -rf apache-aurora-$AURORA_VERSION

  if [ ! -d aurora-packaging ]; then
      git clone "https://github.com/apache/aurora-packaging.git" "aurora-packaging"
  fi

  (cd aurora-packaging && \
  git fetch origin "$AURORA_PACKAGE_BRANCH" && \
  git checkout "$AURORA_PACKAGE_BRANCH" && \
  # build debs for ubuntu-trusty
  ./build-artifact.sh builder/deb/ubuntu-trusty \
          "${BASE_DIR}/snap.tar.gz" \
	  "$AURORA_RELEASE" && \
  find . -name \*aurora-scheduler\*.deb -exec cp {} ${BASE_DIR} \; && \
   # build rpms for centos-7
  ./build-artifact.sh builder/rpm/centos-7 \
          "${BASE_DIR}/snap.tar.gz" \
	  "$AURORA_RELEASE" && \
  find . -name \*aurora-scheduler\*.rpm -exec cp {} ${BASE_DIR} \;)

fi

if [ -z ${GITHUB_TOKEN} ]; then
  echo "Missing GITHUB_TOKEN environment variable"
  exit 1
fi

UPLOAD_URL=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/medallia/aurora/releases/tags/${AURORA_RELEASE} | grep upload_url | awk '{print $2}' | awk -F'{' '{sub(/\"/, "", $1); print $1}' )

if [ -z ${UPLOAD_URL} ]; then
  echo "Could not find release with name ${AURORA_RELEASE}"
  echo "Check release or credentials"
  exit 1
fi

upload aurora-scheduler_${AURORA_RELEASE}_amd64.deb
upload aurora-scheduler-${AURORA_RELEASE//-/_}-1.el7.centos.aurora.x86_64.rpm

echo "Building Docker Image"

docker build -f Dockerfile --build-arg "AURORA_RELEASE=${AURORA_RELEASE}" -t "medallia/${AURORA_IMAGE}" .
