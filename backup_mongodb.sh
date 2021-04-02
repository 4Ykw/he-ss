#!/bin/bash
# Program: Local HIVE-Engine Snapshots Backups (for HE-SS)
# Description: Manages local snapshots backups for your HIVE-Engine witness node via MongoDB dumps and controls your node pm2 process state
# Author: forykw
# Date: 2021/04/02
# v1.0

## Adjust to your node
PM2_PROCESS_NAME="prod-hivengwit"
BACKUPS_DIR="${HOME}"

# Timestamp format for script output
timestamp_format ()
{
        echo "[`date --iso-8601=seconds`] "
}

# Validate if the right process is registered (if not, abort)
if [ `pm2 list | grep prod-hivengwit | wc -l` != "1" ]; then
	echo $(timestamp_format)"Could not find ${PM2_PROCESS_NAME} pm2 process configured... aboring!"
	exit -1
fi

# Validate if the chosen backup directory exists
if [ ! -d ${BACKUPS_DIR} ]; then
	echo $(timestamp_format)"Make sure your backups directory exists (aborting): ${BACKUPS_DIR}"
	exit -1
fi

echo $(timestamp_format)"Starting local backup process.."
echo $(timestamp_format)"Stopping node..."
pm2 stop ${PM2_PROCESS_NAME}
echo $(timestamp_format)"Dumping mongoDB..."
mongodump -d=hsc --gzip --archive=${BACKUPS_DIR}/hsc_`date --iso-8601`_b`cat ${BACKUPS_DIR}/prod/steemsmartcontracts/config.json | grep startHiveBlock | awk '{print $2}' | cut -d "," -f 1`.archive
echo $(timestamp_format)"Dump complete!"
echo $(timestamp_format)"Starting node..."
pm2 start ${PM2_PROCESS_NAME}
echo $(timestamp_format)"Finished local backup process!"
