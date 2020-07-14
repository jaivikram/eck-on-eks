#!/bin/bash

if [[ -z "${NEO4J_S3_PATH}" ]] || [[ -z "${NEO4J_DUMP}" ]]; then
	NEO4J_PATH=""
	NEO4J_FILE=""
else
	NEO4J_PATH=$NEO4J_S3_PATH
	NEO4J_FILE=$NEO4J_DUMP
fi
echo $NEO4J_PATH
echo $NEO4J_FILE

echo "Start restore.sh"
if [ ! -d "/data/databases/graph.db" ]; then
	echo "Remove graph.db folder"
	rm -rf /data/databases/graph.db
	echo "Create graph.db folder"
	mkdir -p /data/databases/
	echo "S3 Sync"
	aws s3 sync $NEO4J_PATH /data/backup/ --exclude="*" --include="${NEO4J_FILE}"
	chown -R neo4j:neo4j /data/backup
	echo "Neo4J Restore"
	neo4j-admin load --from="/data/backup/${NEO4J_FILE}" --database='graph.db'
	echo "Copy to PVC"
	cp -v -R /var/lib/neo4j/data/databases/graph.db /data/databases/
	echo "Delete from Node"
	rm -rf /var/lib/neo4j/data/databases/*
	echo "Change permission on PVC to neo4j"
	chown -R neo4j:neo4j /data/databases
else
	echo "/data/databases directory found"
	ls -la "/data/databases"
fi
echo "Exit restore.sh"
exit 0
