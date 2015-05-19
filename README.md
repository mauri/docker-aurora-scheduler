# Docker image to start an Aurora Scheduler

Using a release from github.com/medallia/aurora.

    docker run --name=aurora-scheduler-1 -e CLUSTER=devcluster \
    -e ZK=z1.example.com:2181,z2.example.com:2181,z3.example.com:2181 \
    -e MESOS_ZK=zk://z1.example.com:2181,z2.example.com:2181,z3.example.com:2181/mesos \
    -e NATIVE_LOG_QUORUM_SIZE=2 \
    -e AURORA_DATA=/opt/aurora   
    -e EXECUTOR_RESOURCES=file:///foo/bar/zaa \
     medallia/aurora-scheduler

## TODO
	
Pull aurora scheduler release from github.com/medallia/aurora and ADD it to the container

