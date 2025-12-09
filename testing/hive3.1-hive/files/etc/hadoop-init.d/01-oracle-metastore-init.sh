#!/bin/bash -ex

# Wait for Oracle container to be ready
echo "Waiting for Oracle Database at ${ORACLE_HOST}:${ORACLE_PORT}..."
for i in {1..60}; do
    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/${ORACLE_HOST}/${ORACLE_PORT}" 2>/dev/null; then
        echo "Oracle Database is reachable"
        break
    fi
    echo "Waiting... attempt $i/60"
    sleep 2
done

# Wait additional time for Oracle to fully initialize
sleep 10

# Initialize Hive metastore schema using schematool
# Note: This assumes the Oracle user 'hive_metastore' and tablespace have been created
# You can create them manually or use Oracle container init scripts:
#
# CREATE TABLESPACE hive_metastore_ts
#   DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/hive_metastore.dbf'
#   SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
# CREATE USER hive_metastore IDENTIFIED BY hive_metastore
#   DEFAULT TABLESPACE hive_metastore_ts QUOTA UNLIMITED ON hive_metastore_ts;
# GRANT CONNECT, RESOURCE, CREATE SESSION, CREATE TABLE, CREATE VIEW,
#   CREATE SEQUENCE, CREATE PROCEDURE TO hive_metastore;

# Check if schema is already initialized by attempting to connect
if /opt/hive/bin/schematool -dbType oracle -info 2>/dev/null | grep -q "schemaTool completed"; then
    echo "Hive metastore schema already initialized"
else
    echo "Initializing Hive metastore schema..."
    /opt/hive/bin/schematool -dbType oracle -initSchema || {
        echo "WARNING: Failed to initialize Hive metastore schema."
        echo "Please ensure the Oracle user 'hive_metastore' exists with proper permissions."
        echo "See script comments for SQL commands to create the user."
        exit 1
    }
fi

echo "Hive metastore initialization complete"
