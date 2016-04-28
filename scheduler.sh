#!/bin/bash
EXECUTOR_HOME=/opt/aurora/executors
AURORA_DATA=/opt/aurora

# Flags controlling the scheduler.
# AURORA_FLAGS=(
#   -cluster_name=$CLUSTER
#   -native_log_quorum_size=$NATIVE_LOG_QUORUM_SIZE
#   -zk_endpoints=$ZK
#   -mesos_master_address=$MESOS_ZK 
#   -thermos_executor_resources=$EXECUTOR_RESOURCES 
# )
AURORA_FLAGS=(
  -http_port=8081 
  -serverset_path=/aurora/scheduler 
  -native_log_zk_group_path=/aurora/replicated-log 
  -native_log_file_path=$AURORA_DATA/scheduler/db 
  -backup_dir=$AURORA_DATA/scheduler/backups
  -thermos_executor_path=$EXECUTOR_HOME/thermos_executor.pex
  -allow_docker_parameters=true
  -allowed_container_types=MESOS,DOCKER 
)

ARGUMENTS=( "${AURORA_FLAGS[@]}" "$@" )

# Flags controlling the JVM.
export JAVA_OPTS="-Djava.library.path=/usr/lib ${JAVA_OPTS}"

# Environment variables controlling libmesos
export GLOG_v=1
export LIBPROCESS_PORT=8083

exec "/usr/sbin/aurora-scheduler" "${ARGUMENTS[@]}"
