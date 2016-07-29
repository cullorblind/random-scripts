#!/bin/sh

#settings
HOME="/home/steam"
RCONPW="$(cat ${HOME}/ark.pw)"
MAP=TheIsland   #TheIsland,TheCenter
OPTIONS="Port=7777"
OPTIONS+="?QueryPort=27015"
OPTIONS+="?ServerCrosshair=true"
OPTIONS+="?AllowThirdPersonPlayer=true"
OPTIONS+="?MapPlayerLocation=true"
OPTIONS+="?MaxStructuresInRange=200"
OPTIONS+="?MaxPlayers=25"
OPTIONS+="?PreventOfflinePvP=true"
OPTIONS+="?PreventOfflinePvPInterval=900"
OPTIONS+=" -ForceAllowCaveFlyers"
OPTIONS+=" -EnableIdlePlayerKick"
OPTIONS+=" -nosteamclient"
OPTIONS+=" -webalarms"
OPTIONS+=" -game"
OPTIONS+=" -server"
OPTIONS+=" -servergamelog"
OPTIONS+=" -culture=en"
OPTIONS+=" -log"

#webalarms needs php written to grab and sqlite for web page.

f_backup () {
echo "[32mbacking up server[0m"
if [ -d ${HOME}/arkdedicated/ShooterGame/Saved ]; then
        echo -e "[33mBacking up Saved folder...[0m\n"
        if [ ! -d ${HOME}/backup/ ]; then
                mkdir ${HOME}/backup/
        fi
        tar czf ${HOME}/backup/Saved-startup_$(date +%Y-%m-%d_%H-%M).tar.gz ${HOME}/arkdedicated/ShooterGame/Saved
fi
}

#Example crontab to check for updates once every four hours
#0 */4 * * * /home/steam/ark.sh checkupdate > /home/steam/checkupdate.cron.log.$$
f_checkupdate () {
	echo "[32mChecking for updates.[0m"
	mv -f ${HOME}/this.version ${HOME}/last.version
	rm -f ${HOME}/Steam/appcache/appinfo.vdf
	${HOME}/steamcmd.sh +login anonymous +app_info_print 376030 +quit | awk '$1 ~ /buildid/ {print $2;exit;}' > ${HOME}/this.version
	#empty file shouldn't be compared. Toss it back and we'll catch it next time.
	if [[ -s ${HOME}/this.version ]];then
		diff ${HOME}/this.version ${HOME}/last.version
		DIFF=$?
	else
		echo "[31mWoops... That file was empty. Reset and try again next time.[0m"
		cp -f ${HOME}/last.version ${HOME}/this.version
		DIFF=0
	fi
}

f_update () {
	echo "[32mupdating server[0m"
	#validate if things are being weird and we need to fully resync.
	#./steamcmd.sh +login anonymous +force_install_dir ${HOME}/arkdedicated +app_update 376030 validate +quit
	${HOME}/steamcmd.sh +login anonymous +force_install_dir ${HOME}/arkdedicated +app_update 376030 +quit
}

f_stop () {
	echo "[32mstopping server[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 saveworld
	sleep 10
	${HOME}/rcon -P"${RCONPW}" -p27020 doexit
}

f_start () {
	echo "[32mstarting server[0m"
	cd ${HOME}/arkdedicated/ShooterGame/Binaries/Linux
	/usr/bin/screen -S ark -A -d -m ./ShooterGameServer ${MAP}?listen?${OPTIONS}
	cd -
}

f_listplayers () {
	echo "[32mPlayers:[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 listplayers
	CHECKSRV=$?
}

f_notifyupdate () {
	echo "[32mnotifying players 15min[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 broadcast "AUTOUPDATE: The server will be restarted in 15 minutes for an update."
	sleep 300
	echo "[32mnotifying players 10min[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 broadcast "AUTOUPDATE: The server will be restarted in 10 minutes for an update."
	sleep 300
	echo "[32mnotifying players 5min[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 broadcast "AUTOUPDATE: The server will be restarted in 5 minutes for an update."
	sleep 240
	echo "[32mnotifying players 1min[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 broadcast "AUTOUPDATE: The server will be restarted in 1 minute for an update."
	sleep 60
	echo "[32mnotifying players NOW[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 broadcast "AUTOUPDATE: The server is NOW going down for an update"
	sleep 5
}

f_serverchat () {
	shift 1
	echo "[32mSending Message[0m"
	${HOME}/rcon -P"${RCONPW}" -p27020 serverchat "$*" 2>/dev/null
}



case "$1" in
'start')
	f_start
;;
'stop')
	f_stop
;;
'restart')
	f_stop
	sleep 5
	f_start
;;
'checkupdate')
	f_checkupdate
	if [[ ${DIFF} -eq 1 ]]
	then
		echo "[32mUpdated repository, Let's update local too.[0m"
		f_listplayers
		if [[ $CHECKSRV = 0 ]];then
			f_notifyupdate
			f_stop
			f_backup
			f_update
			f_start
		else
			echo "[32mServer Not Running. Just backing up and updating.[0m"
			f_backup
			f_update
		fi
	else
		echo "[32mNo Updates.[0m"
	fi
;;
'update')
	#If it responds to player list, then announce, stop, backup, update, and restart.
	#If it's not running, just backup and update.
	f_listplayers
	if [[ $CHECKSRV = 0 ]];then
		f_notifyupdate
		f_stop
		f_backup
		f_update
		f_start
	else
		echo "[32mServer Not Running. Just backing up and updating.[0m"
		f_backup
		f_update
	fi
;;
'backup')
	f_backup
;;
'listplayers')
	f_listplayers
;;
'serverchat')
	f_serverchat $*
;;
*)
	echo "Usage $0 start|stop|restart|update|backup"
;;
esac

