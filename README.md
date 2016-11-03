# Docker image to start an Aurora Scheduler

## Build .rpm and .deb artifacts
In the project directory run:

    $ make build-artifacts

## Publish .rpm and .deb artifacts to Github release
In the project directory run:

    $ export GITHUB_TOKER=token
    $ make publish-artifacts

## Build Docker images
In the project directory, build with

    $ make build-images 

An image medallia/aurora-scheduler:<version>-<os> is generated.

## Running the Container

    docker run --name=aurora-scheduler-1  				\
    medallia/aurora-scheduler:<version>-<os>             				\
    -cluster_name=foo      								\
    -native_log_quorum_size=1      						\
    -zk_endpoints=192.168.0.1:2181						\
    -mesos_master_address=zk://192.168.0.1:2181/mesos	\
    -thermos_executor_resources=file:///.dockercfg
    
___________________________________________________
*Copyright 2016 Medallia Inc. All rights reserved*
