#!/bin/bash
# Program: Snapshots Upload Management Script Using Google Drive (for HE-SS)
# Description: Manages local snapshots for your HIVE-Engine witness node and uploads them offsite to a Google Drive folder
# Author: forykw
# Date: 2021/04/02
# v1.0

# Timestamp format for script output
timestamp_format ()
{
	echo "[`date --iso-8601=seconds`] "
}

echo $(timestamp_format)"Starting upload process..."

# If home variable is not defined, don't run
if [ -z "${HOME}" ]; then
	echo $(timestamp_format)"Please set your \$HOME directory!"
	exit -1
fi

## Adjust to your node
PM2_PROCESS_NAME="prod-hivengwit"
BACKUPS_DIR="${HOME}"
# Google Drive mountpoint
GD_MOUNT="${HOME}/myGoogleDrive"
GD_SUBDIR="hive-engine-snapshots"


# If backup dir does not exist, don't run
if [ ! -d "${BACKUPS_DIR}" ]; then
	echo $(timestamp_format)"Please set your backups directory!"
	exit -1
fi

# Check if GDrive directory is available, if not create the directory defined at GD_MOUNT variable
if [ ! -d "${GD_MOUNT}" ]; then
        echo $(timestamp_format)"GDrive directory not found. Creating one!"
	mkdir -p ${GD_MOUNT}
	echo $(timestamp_format)"Otherwise, if you would like a different path, create one with <mkdir -p new_path> and then edit this script GD_MOUNT variable."
	exit -1
fi

# Mount using casched credentials the GDrive mountpoint
if ! mountpoint -q ${GD_MOUNT}; then 
	google-drive-ocamlfuse -skiptrash ${GD_MOUNT}
	# Validate it got mounted
	if mountpoint -q ${GD_MOUNT}; then
		echo $(timestamp_format)"Mountpoint ${GD_MOUNT} mounted!"
	else
		echo $(timestamp_format)"Mountpoint ${GD_MOUNT} failed to mount... exiting!"
		exit -1
	fi
fi

# Get stats
OLDEST_SNAPSHOT=`ls -lart ${BACKUPS_DIR} | grep hsc | grep archive | awk '{print $9}' | head -n 1`
LAST_SNAPSHOT=`ls -lart ${BACKUPS_DIR} | grep hsc | grep archive | awk '{print $9}' | tail -n 1`
NR_SNAPS=`ls -lart ${BACKUPS_DIR} | grep hsc | grep archive | wc -l`
GD_OLDEST_SNAPSHOT=`ls -lart ${GD_MOUNT}/${GD_SUBDIR} | grep hsc | grep archive | awk '{print $9}' | head -n 1`
GD_LAST_SNAPSHOT=`ls -lart ${GD_MOUNT}/${GD_SUBDIR} | grep hsc | grep archive | awk '{print $9}' | tail -n 1`
GD_NR_SNAPS=`ls -lart ${GD_MOUNT}/${GD_SUBDIR} | grep hsc | grep archive | wc -l`

# Uncomment for Debug Info
#echo ${OLDEST_SNAPSHOT}
#echo ${LAST_SNAPSHOT}
#echo ${NR_SNAPS}
#echo ${GD_OLDEST_SNAPSHOT}
#echo ${GD_LAST_SNAPSHOT}
#echo ${GD_NR_SNAPS}

# Checks (uncomment for visual)
# Remember to unmount the mountpoint if you change the settings at ~/.gdfuse/default/config
echo $(timestamp_format)"Max upload speed (to Google Drive): "`cat ${HOME}/.gdfuse/default/config | grep max_upload_speed | cut -d "=" -f 2`" bytes/s"


# Check if the last snapshot is not actual
echo $(timestamp_format)"Total number of Google Drive snapshots (before deletion): ${GD_NR_SNAPS}"
if [ ! "${LAST_SNAPSHOT}" == "${GD_LAST_SNAPSHOT}" ]; then

	# Define max snapshots to maintain on Google Drive
	if [ `printf '%d\n' "${GD_NR_SNAPS}"` -gt 2 ]; then
		# Remove oldest snapshot
		rm ${GD_MOUNT}/${GD_SUBDIR}/${GD_OLDEST_SNAPSHOT}
		echo $(timestamp_format)"Deleted Google Drive oldest snapshot: ${GD_OLDEST_SNAPSHOT}"
	fi

	## Rsync last snapshot
	## Switch the following two rsync lines if you wish the rsync bandwidth to be limited to a certain speed (this is not the speed of the upload to google).
	## This will usually help if you want to limit the read IOs of your disk while the witness node is already up and running.
	
	# Limited to 100MB/s
	#rsync -avi --progress --stats --bwlimit=100M ${BACKUPS_DIR}/${LAST_SNAPSHOT} ${GD_MOUNT}/${GD_SUBDIR}/
	
	# Without bandwidth limits (default)
	rsync -avi --progress --stats ${BACKUPS_DIR}/${LAST_SNAPSHOT} ${GD_MOUNT}/${GD_SUBDIR}/
else
	echo $(timestamp_format)"Google Drive last uploaded snapshot is the most recent one!"
fi

# Perform local cleanup after upload completes or validation that we have the most updated snapshot already on Google Drive
echo $(timestamp_format)"Total number of local snapshots (before deletion): ${NR_SNAPS}"
if [ `printf '%d\n' "${NR_SNAPS}"` -gt 2 ]; then
	# Remove oldest snapshot
        rm ${BACKUPS_DIR}/${OLDEST_SNAPSHOT}
        echo $(timestamp_format)"Deleted local oldest snapshot: ${OLDEST_SNAPSHOT}"
fi

echo $(timestamp_format)"Finished upload process!"

