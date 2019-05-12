#!/usr/bin/env bash
source ./kafka_common.sh

start_zookeeper
echo -e "wait for zookeeper to start... "
sleep 5
start_broker
