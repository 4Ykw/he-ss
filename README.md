# HIVE-Engine Snapshots Service (HE-SS)

This is a collection of bash scripts to automate the Hive-Engine Witness node snapshots backups.

## `he_ss.sh` v1.0
Name of the executable bash script that runs from anywhere you deploy.

## Configurables
Inside the provided scripts are some variables allowing you to customise or adapt to your node infrastructure.

### 1. `backup_mongodb.sh` v1.1
  - `PM2_PROCESS_NAME` - The name of your pm2 Hive-Engine node process. __(mandatory)__
  - `BACKUPS_DIR` - The backup directory to host your local snapshots (defaults to your home directory)
  - `WITNESS_NODE_DIR` - The directory where your Hive-Engine node runs from. (defaults to ~/prod/steemsmartcontracts) __(mandatory)__
### 2. `upload_archive_gdrive.sh` v1.0
  - `PM2_PROCESS_NAME` - The name of your pm2 Hive-Engine node process. __(mandatory)__
  - `BACKUPS_DIR` - The backup directory to host your local snapshots (defaults to your home directory)
  - `GD_MOUNT` - The Google Drive local mountpoint (defaults to your home directory plus myGoogleDrive subdirectory)
  - `GD_SUBDIR` - The remote directory on your Google Drive to host your snapshots (defaults to hive-engine-snapshots)
### 3. `test_commands.sh` v1.1 - (no configurables)

## How to start
Change the variable `PM2_PROCESS_NAME` inside the `backup_mongodb.sh` and the `upload_archive_gdrive.sh` scripts to the name of your pm2 process. Then simply execute the script:
```
[he-ss_cloned_directory]> ./he_ss.sh
```

Alternatively you can specify a log file and then `tail -f` that log:
```
[he-ss_cloned_directory]> ./he_ss.sh >> ./he_ss.log 2>&1
```

## How to stop
Ctrl+C or kill all the pids from the main script and dependent ones (use `ps -ef | grep <search>` to find it)

# Running via crontab
Before you install a crontab entry to run this, be sure to comment the following lines inside the `he_ss.sh` script (if you are not sure of what you are doing):
```
## Main Tasks
# 1st dump MongoDB locally (will stop/start your node)
./backup_mongodb.sh
# 2nd upload the snapshot to Google Drive via local mount and manage amount of snapshots locally and remotely
./upload_archive_gdrive.sh
```

Then add a crontab entry (`crontab -e`) such as (for example):
```
# Runs the script at 3 AM, every day
0 3 * * * cd /<location_of_he-ss_script>; ./he_ss.sh >> ./he_ss.log 2>&1
```

If the output of the `he_ss.log` shows no errors, you are safe to uncomment the commented above lines and run the script via crontab.
Otherwise you might need to add further paths to the PATH variable in order for those commands to run.

# Features
 - MongoDB node managed dumps (snapshots)
 - Manages witness unregistration (to avoid missing blocks)
 - Uploading of snapshots backups to Google Drive with both remote and local rotation (in terms of number of backups)
 - Control of the transfer speeds:
   1. Local disk read speed of the upload...
   2. Average upload speed to Google Drive

# Feedback / Contacts
Feel free to submit any feature requests/bugs via github or to contact me on HIVE via @forykw account.
