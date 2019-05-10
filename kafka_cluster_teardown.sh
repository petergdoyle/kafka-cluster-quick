#!/usr/bin/env bash
source ./kafka_common.sh

kill_brokers
sleep 2
kill_zookeepers
sleep 2
cleanup_kafka_logs
