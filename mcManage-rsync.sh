#!/bin/bash
# Minecraft AutoBackup

#Minecraft Home Directory
HOME='/home/minecraft/McMyAdmin/'
touch ${HOME}

#Screen session name
SCREENSESSION='mcmyadmin'

#check server, pause saving, save, backup, and resume saving.
nc mc1.ke5kul.prwn.net 25565 < /dev/null
if [ $? = 0 ] #check if server is running
then #Inform players that backup started
#   /usr/bin/screen -S ${SCREENSESSION} -X stuff "say ###Cullor Rsync Backup - Started###"`echo -ne '\015'`
   /usr/bin/screen -S ${SCREENSESSION} -X stuff "save-off"`echo -ne '\015'`
   /usr/bin/screen -S ${SCREENSESSION} -X stuff "save-all"`echo -ne '\015'`
   /usr/bin/rsync -avr --delete --progress --stats ${HOME} backups.ke5kul.prwn.net::mc1/0-latest/
   /usr/bin/screen -S ${SCREENSESSION} -X stuff "save-on"`echo -ne '\015'`
#   /usr/bin/screen -S ${SCREENSESSION} -X stuff "say ###Cullor Rsync Backup - Complete###"`echo -ne '\015'`
   exit 0
else #server's not running, so no need to make another backup.
   exit 1
fi

