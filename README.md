# Docker image to start an Aurora Scheduler

## Build Artifacts
Build .rpm and .deb artifacts for ubuntu-trusty and centos-7.
In the project directory run:

    $ make build-artifacts

## Publish Artifacts
Publish .rpm and .deb artifacts to Github release.
In the project directory run:

    $ export GITHUB_TOKEN=token
    $ make publish-artifacts

## Build Docker images
Build Docker images for the operating system types under `dockerfile-templates` folder.
In the project directory run:

    $ make build-images 

Image tags are obtained from the TAG files.

## Publish images
Push tagged images to the repository. 

    $ make publish-images

## Running the Container

    docker run --name=aurora-scheduler-1  \
    medallia/aurora-scheduler:<tag> \	
    -cluster_name=foo \
    -native_log_quorum_size=1 \
    -zk_endpoints=192.168.0.1:2181 \
    -mesos_master_address=zk://192.168.0.1:2181/mesos \
    -thermos_executor_resources=file:///.dockercfg
    
___________________________________________________
*Copyright 2016 Medallia Inc. All rights reserved*
