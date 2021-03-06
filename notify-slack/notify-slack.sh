#!/bin/sh

#--- TODO ---#
# * Probably rewrite in Perl.
# * More stuff to strip from EXECOUTPUT becuase occasional invalid payload happens still
# * More safety checks
#   - Capture status output from curl and determine action if it's not "ok" (email/some other alert mechanism)
#   - limit output of execute output to 4k. (saw this limit in slacks documentation somewhere)
#   - prevent spamming - repeating the same message
#   - rate limits = https://api.slack.com/docs/rate-limits
# * Allow sending messaged to @users instead of #channels (Partial, but still needs work)

#--- ENV ---# configure these as defaults if not called from command line
function f_env
{
	# Defaults if not defined at command line.
	WEBHOOKURL="${WEBHOOKURL:-<WEBHOOK URL GOES HERE>}"
	DESTINATION="${DESTINATION:-#alerts}" # eg. #channel eg2. @person"
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

 Usage    : notify_slack.sh [-u webhookurl] [-c channel] [-e emoji] [-b botname] [-x "/path/to/executable"] <-m "message">

 Arg Desc : -u (webhookurl) eg. "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX}"
            -c (channel)   default:  #alerts     (channel name with preceding # included)
            -e (emoji)     default:  :alien:
            -b (botname)   default:  CLIBOT
            -m "(message)" "make sure it's in quotes"
            -n             NOTIFY @channel
            -x (execute)   "/path/to/executable -and options" - capture output of command and attach

                *NOTE* Output of executed command should be 80 columns wide or it will be word wrapped.
                *NOTE* Executed output should be no more than 4 KiloBytes.
                *NOTE* You should not allow this alert to be called more than once per second per slacks API guidelines.

 Examples : Send a simple message to the default channel
          : notify_slack.sh -m "This is a test message from the command line"
          : Send an alert with a top 5 disk usage report attached to #alerts-unix as TUXBOT with :tux: icon.
          : notify_slack.sh -c alerts-unix -e :tux: -b TUXBOT -m "/var is at 90% utilization" -x "/usr/local/bin/gbf -top 5 -dir /var"

USAGE
}


#--- GET OPTIONS ---#
while getopts ":u:c:e:b:x:nm:h" arg; do
	case $arg in
		u) WEBHOOKURL=${OPTARG} ;;
		c) DESTINATION=${OPTARG} ;;
		e) ICON_EMOJI=${OPTARG} ;;
		b) BOTNAME=${OPTARG} ;;
		x) EXECUTE=${OPTARG} ;;
		n) NOTIFYCHAN='<!channel>' ;;
		m) MSG=${OPTARG}
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
		EXECOUTPUT=$(echo ${EXECOUTPUT} | sed 's/"//g')
		EXECOUTPUT=$(echo ${EXECOUTPUT} | sed 's/&/\&amp;/g')
		EXECOUTPUT=$(echo ${EXECOUTPUT} | sed 's/</\&lt;/g')
		EXECOUTPUT=$(echo ${EXECOUTPUT} | sed 's/>/\&gt;/g')

		/bin/curl -X POST --data-urlencode "payload={\"channel\": \"${DESTINATION}\", \"icon_emoji\": \"$ICON_EMOJI\", \"username\": \"${BOTNAME}\", \"attachments\": [ { \"color\": \"#f6364f\", \"text\": \"${MESSAGE}\", \"footer\": \":prwn: ${ID}@${HOSTNAME}:${PARENT_COMMAND#* } ${NOTIFYCHAN}\" }, { \"color\": \"#4636ff\", \"text\": \"\`\`\`# ${EXECUTE}${EXECOUTPUT}\`\`\`\", \"mrkdwn_in\": [ \"text\" ] } ] }" ${WEBHOOKURL}

	else

		/bin/curl -X POST --data-urlencode "payload={\"channel\": \"${DESTINATION}\", \"icon_emoji\": \"$ICON_EMOJI\", \"username\": \"${BOTNAME}\", \"attachments\": [ { \"color\": \"#f6364f\", \"text\": \"${MESSAGE}\", \"footer\": \":prwn: ${ID}@${HOSTNAME}:${PARENT_COMMAND#* } ${NOTIFYCHAN}\" } ] }" ${WEBHOOKURL}

	fi

else

  echo "no message defined"

fi
