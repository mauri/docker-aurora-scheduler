#!/bin/bash
AURORA_HOME=/usr/local/aurora-scheduler
EXECUTOR_HOME=/opt/aurora/executors

# Flags controlling the JVM.
JAVA_OPTS=(
  -Xmx2g
  -Xms2g
  -Djava.library.path=/usr/lib
  # GC tuning, etc.
)

# Flags controlling the scheduler.
AURORA_FLAGS=(
  -cluster_name=$CLUSTER
  -http_port=8081 
  -native_log_quorum_size=$NATIVE_LOG_QUORUM_SIZE
  -zk_endpoints=$ZK
  -mesos_master_address=$MESOS_ZK 
  -serverset_path=/aurora/scheduler 
  -native_log_zk_group_path=/aurora/replicated-log 
  -native_log_file_path=$AURORA_DATA/scheduler/db 
  -backup_dir=$AURORA_DATA/scheduler/backups
  -thermos_executor_path=$EXECUTOR_HOME/thermos_executor.pex
  -thermos_executor_resources=$EXECUTOR_RESOURCES 
  -allow_docker_parameters=true
  -vlog=INFO 
  -logtostderr 
  -allowed_container_types=MESOS,DOCKER 
)

# Environment variables controlling libmesos
export GLOG_v=1
export LIBPROCESS_PORT=8083

JAVA_OPTS="${JAVA_OPTS[*]}" exec "$AURORA_HOME/bin/aurora-scheduler" "${AURORA_FLAGS[@]}"
