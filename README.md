# random-scripts

* **aprxlogcolor.pl** - hacked up logcolor.pl to do aprx logs.
* **aprxlogcolor2.pl** - hacked up logcolor.pl to do aprx logs. Added local digis array.
* **aprx-rf.sec** - Monitor aprx rf log for 15 minute inactivity of packets received from TNC and call notify-slack if there's a problem.

![Example of aprslogcolor2.pl](http://i.imgur.com/oV8OPXA.png)

* **mcManage-rsync.sh** - Minecraft server - Backup script that will pause/resume saving for rsync copy.
* **notify-slack.sh** - Notification script for pushing alerts to slack.
** Can attach output of a command. eg. gbf reports/log tail/etc.

![Example Slack notification](http://i.imgur.com/yTulwGJ.png)

* **gbf** - perl script to generate a report of large files, large directories, and directories with high file counts.

![Example gbf report](http://i.imgur.com/PiNkCeb.png)


# Deprecated
* **rotate-backups.sh** - Backup server - Hard link based backup rotation script with s3cmd to keep offsite copies synced.
  * I'm using zfs + snapshots to handle this now.
