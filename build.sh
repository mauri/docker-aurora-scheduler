#! /bin/bash
set -e 

REV="0.10.0-medallia-cmd"

if [ ! -d "aurora" ]; then
	git clone git@github.com:medallia/aurora.git
fi

(cd aurora && git checkout "$REV" && ./gradlew distZip)
DIST_VER=$(cat aurora/.auroraversion)
unzip -d usr/local "aurora/dist/distributions/aurora-scheduler-$DIST_VER.zip"

docker build -t aurora-scheduler-test: .




