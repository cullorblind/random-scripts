#!/bin/sh

#--- ENV ---# configure these as defaults if not called from command line
function f_env
{
	# Defaults if not defined at command line.
	WEBHOOKURL="${WEBHOOKURL:-<WEBHOOK URL GOES HERE>}"
	CHANNEL="${CHANNEL:-alerts}"
	ICON_EMOJI="${ICON_EMOJI:-:alien:}"
	BOTNAME="${BOTNAME:-CLIBOT}"

	# Default to blank if not set.
	MESSAGE="${MSG:-}"
	EXECUTE="${EXECUTE:-}"
}

#--- USAGE ---#
function f_usage
{
cat <<USAGE

 Script   : notify_slack.sh
 Purpose  : Send alerts to Slack
            Also tracks where it was called from to aid in troubleshooting.

 Usage    : notify_slack.sh [-u webhookurl] [-c channel] [-e emoji] [-b botname] <-m 'message'>

 Arg Desc : -u (webhookurl) eg. "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX}"
            -c (channel)   default:  alerts     (channel name with preceding # excluded)
            -e (emoji)     default:  :alien:
            -b (botname)   default:  CLIBOT
            -m (message)   "make sure it's in quotes"
            -x (execute)   "/path/to/executable -and options" - capture output of command and attach

 Examples : Send a simple message to the default channel
          : notify_slack.sh -m "This is a test message from the command line"
          : Send an alert with a top 5 disk usage report attached to #alerts-unix as TUXBOT with :tux: icon.
          : notify_slack.sh -c alerts-unix -e :tux: -b TUXBOT -m "/var is at 90% utilization" -x "/usr/local/bin/gbf -top 5 -dir /var"

USAGE
}


#--- GET OPTIONS ---#
while getopts ":u:c:e:b:x:m:h" arg; do
	case $arg in
		u) WEBHOOKURL=${OPTARG} ;;
		c) CHANNEL=${OPTARG} ;;
		e) ICON_EMOJI=${OPTARG} ;;
		b) BOTNAME=${OPTARG} ;;
		x) EXECUTE=${OPTARG} ;;
		m) MSG=${OPTARG}
			#--- Strip/Replace characters that cause problems --#
			MSG=$(echo ${MSG} | tr -d '\n')
			MSG=$(echo ${MSG} | sed 's/"//g')
			MSG=$(echo ${MSG} | sed 's/&/\&amp;/g')
			MSG=$(echo ${MSG} | sed 's/</\&lt;/g')
			MSG=$(echo ${MSG} | sed 's/>/\&gt;/g')
		;;
		h) f_usage; exit 0 ;;
	esac
done

f_env

#--- WHOAMI ---# fills in the rest so we know where it's coming from.
PARENT_COMMAND="$(ps -o args= $PPID)" #who or what process called this script
HOSTNAME=$(/bin/hostname)
ID=$(/bin/id -un)


#--- THEREST ---#
if [[ ${MESSAGE} ]]; then

  if [[ ${EXECUTE} ]]; then
    EXECOUTPUT="$(eval ${EXECUTE})"
    /bin/curl -X POST --data-urlencode "payload={\"channel\": \"#${CHANNEL}\", \"icon_emoji\": \"$ICON_EMOJI\", \"username\": \"${BOTNAME}\", \"attachments\": [ { \"color\": \"#f6364f\", \"text\": \"${MESSAGE}\", \"footer\": \":prwn: ${ID}@${HOSTNAME}:${PARENT_COMMAND#* } <!channel>\" }, { \"color\": \"#4636ff\", \"text\": \"\`\`\`# ${EXECUTE}${EXECOUTPUT}\`\`\`\", \"mrkdwn_in\": [ \"text\" ] } ] }" ${WEBHOOKURL}
  else
    /bin/curl -X POST --data-urlencode "payload={\"channel\": \"#${CHANNEL}\", \"icon_emoji\": \"$ICON_EMOJI\", \"username\": \"${BOTNAME}\", \"attachments\": [ { \"color\": \"#f6364f\", \"text\": \"${MESSAGE}\", \"footer\": \":prwn: ${ID}@${HOSTNAME}:${PARENT_COMMAND#* } <!channel>\" } ] }" ${WEBHOOKURL}
  fi

else

  echo "no message defined"

fi