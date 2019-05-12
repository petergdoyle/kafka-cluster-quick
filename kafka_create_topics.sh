#!/usr/bin/env bash

zk_host_port="localhost:2181"
read -e -p "Enter Zk host:port address: " -i "$zk_host_port" zk_host_port

$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $zk_host_port --replication-factor 1 --partitions 2 --topic logs --config max.message.bytes=262144 --config retention.bytes=26214400 --config retention.ms=3600000
$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $zk_host_port --replication-factor 1 --partitions 2 --topic logs-stderr --config max.message.bytes=262144 --config retention.bytes=26214400 --config retention.ms=3600000
$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $zk_host_port --replication-factor 1 --partitions 2 --topic logs-stdout --config max.message.bytes=262144 --config retention.bytes=26214400 --config retention.ms=3600000
$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $zk_host_port --replication-factor 1 --partitions 2 --topic logs-reduced --config max.message.bytes=262144 --config retention.bytes=26214400 --config retention.ms=3600000
