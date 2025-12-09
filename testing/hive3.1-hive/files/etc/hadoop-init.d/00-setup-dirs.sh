#!/bin/bash -e

# Create required log directories for supervisord
mkdir -p /var/log/hadoop-hdfs
mkdir -p /var/log/hive
mkdir -p /var/log

echo "Log directories created successfully"
