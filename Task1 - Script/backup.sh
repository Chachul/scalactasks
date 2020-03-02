#!/bin/bash

DIRS=("$@")
DAY=$(date +%F)
HOSTNAME=$(hostname -s)
ARCHIVE_FILE="/tmp/$HOSTNAME-$DAY.tgz.gpg"
REMOTE_DIR="/home"
REMOTE_SERVER=52.29.210.35

validate_if_dir_exist () {
	for dir in $DIRS; do
		if [ ! -d "$dir" ]; then
			echo "Directory $dir doesn't exist, exiting script"
			exit 1
		fi
	done
}

compress_directory () {
	tar -chzf - "${DIRS[@]}" | gpg --symmetric --cipher-algo aes256 -o $ARCHIVE_FILE
}

send_to_server () {
	rsync -avze "ssh -i EC2Tutorial.pem" $ARCHIVE_FILE ec2-user@$REMOTE_SERVER:$REMOTE_DIR
}

cleanup () {
	if [ -f $ARCHIVE_FILE ]; then
		rm -rf $ARCHIVE_FILE
	fi
}

validate_if_dir_exist

compress_directory

send_to_server

trap cleanup INT EXIT TERM QUIT