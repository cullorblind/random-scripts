#!/bin/sh
#
# * Backups are rsynced into the latest folder at 15 minute increments.
# * some logic could probably be done to make it more efficient.  eg. at the top of the hour,
#   do one copy for hourly and skip 15min, but I'm lazy and this works fairly well.
# * This normally runs on a separate server from the minecraft instance so that disk I/O contention
#   is not an issue.
#
# cron jobs should be added for s3, 15min, 2hour, and daily rotations with offsets to prevent ovarlapping.
# eg.
#*/15 * * * * /mcbackups/mc1/rotate-backups.sh 15min >/mcbackups/mc1/rotate-15min.log 2>&1
#11 */2 * * * /mcbackups/mc1/rotate-backups.sh 2hour >/mcbackups/mc1/rotate-2hour.log 2>&1
#21 0 * * * /mcbackups/mc1/rotate-backups.sh s3 >/mcbackups/mc1/rotate-s3.log 2>&1
#31 0 * * * /mcbackups/mc1/rotate-backups.sh daily >/mcbackups/mc1/rotate-daily.log 2>&1

BASEDIR=/mcbackups/mc1
DURATION=$1

if [[ $DURATION == 15min ]]
then
	LASTNUM=08
	COUNT=$(echo {07..01})
elif [[ $DURATION == 2hour ]]
then
	LASTNUM=12
	COUNT=$(echo {11..01})
elif [[ $DURATION == daily ]]
then
	LASTNUM=08
	COUNT=$(echo {07..01})
elif [[ $DURATION == s3 ]]
then
	/bin/s3cmd sync --delete-removed /mcbackups/mc1/0-latest/MentalMetal/ s3://MentalMetalbackup
	exit 0
else
	echo "$DURATION not set properly"
	exit 1
fi


/bin/rm -rf ${BASEDIR}/${DURATION}-${LASTNUM}

for NUM in $COUNT
do
	/bin/mv ${BASEDIR}/${DURATION}-${NUM} ${BASEDIR}/${DURATION}-${LASTNUM}
	LASTNUM=$NUM
done

/bin/cp -al ${BASEDIR}/0-latest ${BASEDIR}/${DURATION}-${NUM}
/bin/touch ${BASEDIR}/${DURATION}-${NUM}
