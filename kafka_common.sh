#!/usr/bin/env bash

if [ -z "$KAFKA_HOME" ]; then
  echo "ENV variable KAFKA_HOME is not set. KAFKA_HOME must be set"
  return 1
fi

zookeeper_logs_dir="/tmp/zookeeper"
zookeeper_logs_myid="$zookeeper_logs_dir/myid"
kafka_logs_dir="/tmp/kafka-logs"

function start_zookeeper() {

  zk_id="1"
  read -e -p "Enter Zk id. Must be unique per cluster: " -i "$zk_id" zk_id

  zk_port="2181"
  read -e -p "Enter Zk client port. Must be unique per Zk instance on a single machine: " -i "$zk_port" zk_port

  mkdir $zookeeper_logs_dir
  echo "$zk_id" > $zookeeper_logs_myid

  properties_template_file="$PWD/config/kafka-zookeeper-template.properties"
  properties_file="$KAFKA_HOME/config/zookeeper-$zk_id".properties
  log_file="$KAFKA_HOME/logs/zookeeper-$zk_id"-console.log

  sed "s/#ZK_PORT#/"$zk_port"/g" $properties_template_file > $properties_file

  echo -e "starting zookeeper $zk_id on port $zk_port ..."

  $KAFKA_HOME/bin/zookeeper-server-start.sh $properties_file > $log_file 2>&1 &
  sleep 2

  PIDS=`ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`
  if [[ ! -z $PIDS ]]; then
    timeout 5s tail -f $log_file
  else
    echo -e "Something went wrong. Zookeeper ($zk_id) does not appear to be running. Checking the log file..."
    sleep 2
    if [ -f $log_file ]; then
      less -f $log_file
    fi
  fi

}

function start_broker() {

  broker_id="1"
  read -e -p "Enter Broker id. Must be unique per cluster: " -i "$broker_id" broker_id

  broker_port="9092"
  read -e -p "Enter Broker port. Must be unique per cluster node: " -i "$broker_port" broker_port

  properties_template_file="$PWD/config/kafka-broker-template.properties"
  properties_file="$KAFKA_HOME/config/broker-$broker_id".properties
  log_file="$KAFKA_HOME/logs/broker-$broker_id"-console.log

  sed "s/#BROKER_ID#/"$broker_id"/g" $properties_template_file > $properties_file
  sed -i "s/#BROKER_PORT#/"$broker_port"/g" $properties_file

  echo -e "starting broker $broker_id on port $broker_port ..."
  export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
  $KAFKA_HOME/bin/kafka-server-start.sh $properties_file > $log_file 2>&1 &
  sleep 2

  PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
  if [[ ! -z $PIDS ]]; then
    timeout 5s tail -f $log_file
  else
    echo -e "Something went wrong. Broker ($broker_id) does not appear to be running. Checking the log file..."
    sleep 2
    if [ -f $log_file ]; then
      less -f $log_file
    fi
  fi

}

function tail_zookeeper_logs() {
  tail $KAFKA_HOME/logs/zookeeper-*.log
}

function tail_broker_logs() {
  tail $KAFKA_HOME/logs/broker-*.log
}

function cleanup_kafka_logs() {
  cleanup_broker_logs
  cleanup_zookeeper_logs
}

function cleanup_broker_logs() {
  rm -fvr $kafka_logs_dir
}

function cleanup_zookeeper_logs() {
  rm -fvr $zookeeper_logs_dir
}

function kill_brokers() {
  PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')
  if [ -z "$PIDS" ]; then
    echo -e "No kafka broker process(es) found to stop."
    return 0
  else
    for each in $PIDS; do
      echo -e "about to terminate process ${each}..."
      sleep 1
      if kill -TERM $each ; then
	echo -e "Terminated process ${each}."
      else
	echo -e "Failed to terminate process ${each}!"
      fi
    done
  fi
}

function kill_zookeepers() {
ZK_PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')
if [ -z "$ZK_PIDS" ]; then
  echo -e "No kafka zookeeper process(es) found to stop"
  return 0
else
  for each in $ZK_PIDS; do
    echo -e "about to terminate process ${each}..."
    sleep 1
    if kill -TERM $each ; then
	echo -e "Terminated process ${each}."
    else
	echo -e "Failed to terminate process ${each}!"
    fi
  done
fi
}

function tail_broker_logs() {
  tail -f $KAFKA_HOME/logs/broker-*log
}

function tail_zookeeper_logs() {
  tail -f $KAFKA_HOME/logs/zookeeper-*log
}

function check_zookeeper_status() {
  ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`
  [[ ! -z $ZK_PIDS ]] \
    && echo -e "Zookeeper process(es) running:\n$ZK_PIDS" \
    || echo -e "Zookeeper process(es) running: No Zookeeper processes running"
}

function check_broker_status() {
  BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
  [[ ! -z $BKR_PIDS ]] \
    && echo -e "Kafka Broker process(es) running:\n$BKR_PIDS" \
    || echo -e "Kafka Broker process(es) running: No Kafka Broker processes running"
}

function open_firewall() {
  firewall-cmd --zone=public --add-port=2181/tcp
  firewall-cmd --zone=public --add-port=2888/tcp
  firewall-cmd --zone=public --add-port=3888/tcp
  firewall-cmd --zone=public --add-port=9092/tcp
}
