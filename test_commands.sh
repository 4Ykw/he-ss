#!/bin/bash
# Program: Crontab Command Test Helper (for HE-SS)
# Description: Validates all required commands can sucessfully execute from crontab before enabling the script for production
# Author: forykw
# Date: 2021/04/03
# v1.1

# This script needs to run from crontab to test the commands run sucessfully, by evaluating its output
`which echo` "### Start of test_commands.sh script"
echo "echo works"
echo "one two grep works" | grep grep
echo "one two grep awk works" | awk '{ print $4" "$5 }'
echo "one two grep awk cut works" | cut -d " " -f 5-
echo "pm2 version: "`pm2 --version`
cat --version > /dev/null && echo "cat works"
echo "date works, current date: "`date`
echo "tail works" | tail -n 1
echo "head works" | head -n 1
ls -lart > /dev/null && echo "ls works"
echo "wc works and this line has this many words: "`echo "wc works and this line has this many words: " | wc -w`
mongodump --version | head -n 3
rm --version > /dev/null && echo "rm works"
printf "printf works\n"
rsync --version > /dev/null && echo "rsync works"
mountpoint --version > /dev/null && echo "mountpoint works"
google-drive-ocamlfuse -version | head -n 1
cd . && echo "cd works"
echo "node version: "`node -v`
sleep --version > /dev/null && echo "sleep works"
echo "### End of test_commands.sh script (carefully inspect output above)"
