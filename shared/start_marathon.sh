#!/bin/bash

cd $HOME/bin/marathon-1.3.0-RC4
MESOS_WORK_DIR=/var/lib/mesos ./bin/start --master localhost:5050 --zk zk://localhost:2181/marathon
