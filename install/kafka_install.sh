#!/usr/bin/env bash

if [ -z "$KAFKA_HOME" ]; then

  mkdir -pv /usr/kafka
  curl -O https://archive.apache.org/dist/kafka/0.10.2.1/kafka_2.11-0.10.2.1.tgz
  tar -xvf kafka_2.11-0.10.2.1.tgz -C /usr/kafka/
  ln -s /usr/kafka/kafka_2.11-0.10.2.1/ /usr/kafka/default
  rm -fr kafka_2.11-0.10.2.1.tgz

  if [ ! -f /etc/profile.d/kafka.sh ]; then
    cat <<EOF >>/etc/profile.d/kafka.sh
export KAFKA_HOME=/usr/kafka/default
export PATH=\$PATH:\$KAFKA_HOME/bin
EOF
  fi

fi
