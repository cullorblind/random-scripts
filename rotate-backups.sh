#!/bin/sh

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
	LASTNUM=15
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
