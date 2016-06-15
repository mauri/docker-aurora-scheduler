# Docker image to start an Aurora Scheduler

## Build Docker Image
In the project directory, build with

    $ ./build.sh 

An image medallia/aurora-scheduler:version is generated.

## Running the Container

    docker run --name=aurora-scheduler-1  				\
    medallia/aurora-scheduler             				\
    -cluster_name=foo      								\
    -native_log_quorum_size=1      						\
    -zk_endpoints=192.168.0.1:2181						\
    -mesos_master_address=zk://192.168.0.1:2181/mesos	\
    -thermos_executor_resources=file:///.dockercfg
    
