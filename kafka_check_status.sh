#!/usr/bin/env bash
source ./kafka_common.sh

check_zookeeper_status
echo -e "tail on zookeeper log(s) 5 seconds..."
sleep1
cmd="timeout 5s tail -f $KAFKA_HOME/logs/zookeeper-*-console.log"
echo "$cmd"
eval "$cmd"
check_broker_status
echo -e "tail on broker log(s) 5 seconds..."
sleep1
cmd="timeout 5s tail -f $KAFKA_HOME/logs/broker-*-console.log"
echo "$cmd"
eval "$cmd"
