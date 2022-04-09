#!/bin/bash

# Set up variables
backup_name="gentoo-backup-$(date +%Y-%m-%d)"
local_backup_path="/backup"

remote_server="192.168.178.2"
remote_user="jannik"
remote_destination="/volume1/Jannik/backup/linux"


# Check for root privileges
if [ "$EUID" = 0 ] ; then 
	echo "Please run this script without privileged access!"
	exit
fi

# Ask for beeing verbose
read -p "Be verbose? [y/n] " user_input
if [ $user_input = "y" ] ; then
	be_verbose=true
else
	be_verbose=false
fi

if $be_verbose ; then
	verbose_command="--progress"
	#echo $verbose_command
else
	verbose_command=""
fi

# Save user password neccessary to run borg backup
read -p "Enter passphrase for privileg elevation: " -s password_elevation; echo
#read -p "Enter passphrase for borg backup: " -s password_borg; echo

#function pipe_password () {
#	$(sleep 2) printf "%s\n" $1 | sudo --stdin $2
#}

#function create_backup () {
#	# This shouldn't work. But it does. But somehow it doesn't either. Don't touch!
#	pipe_password "$password_borg" "borg create $verbose_command --stats \
#	--exclude-from /backup/EXCLUDEFILE --noatime --compression zstd \
#	$local_backup::$backup_name /home/jnnk"
#}

# :(

# Start backup process
echo "Starting backup creation of $backup_name..."
printf "%s\n" $password_elevation | sudo --stdin borg create $verbose_command --stats \
--exclude-from /backup/EXCLUDEFILE --noatime --compression zstd \
$local_backup_path::$backup_name /home/jnnk
printf "%s\n" $password_elevation | sudo --stdin borg compact $local_backup_path


# Ask for remote upload of archived backup
read -p "Upload the backup to remote location? [y/n] " user_input

if [ $user_input = "y" ] ; then
	push_to_cloud=true
elif [ $user_input = "n" ] ; then
	push_to_cloud=false
	echo "Terminating."
else
	echo "Invalid user input. Terminating."
fi

if $push_to_cloud ; then
	echo "Strating upload..."
	printf "%s\n" $password_elevation | sudo --stdin borg export-tar \
	$verbose_command $local_backup_path::$backup_name - | \
	ssh $remote_user@$remote_server -t "echo; cd $remote_destination; cat > $backup_name.tar"
fi

echo; echo "Backup process finished"
