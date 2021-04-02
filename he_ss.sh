#!/bin/bash
# Program: HIVE-Engine Snapshots Service (HE-SS)
# Description: Manages MongoDB Dumps for your HIVE-Engine witness and uploads them offsite
# Author: forykw
# Date: 2021/04/02
# v1.0

# Default export locations tested in Ubuntu
export PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ATTENTION!!! - Use this script (test_commands.sh) first (and then you can comment it) via crontab to validate bellow scripts will work!
# To do so, execute this script, "he_ss.sh" via crontab (but comment all lines after "Main Tasks" section)
# ie. (to start the script at 3 AM of you system date): 0 3 * * * cd /path_where_hs_ss.sh_is; ./he_ss.sh >> ./he_ss.log 2>&1
# If there is need, add more paths to the export line above until this executes without errors
./test_commands.sh

## Main Tasks
# 1st dump MongoDB locally (will stop/start your node)
./backup_mongodb.sh
# 2nd upload the snapshot to Google Drive via local mount and manage amount of snapshots locally and remotely
./upload_archive_gdrive.sh
