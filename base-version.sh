#!/bin/bash
GIT_TERMINAL_PROMPT=0
function fver {
	# Only log as a failure when inst_ver is also unknown.
	# If inst_ver is set, upstream sources are temporarily unreachable/stale —
	# return the installed version silently rather than spamming the log.
	if [[ -z "$2" ]]; then
		echo "$(date +"%r %d/%m/%Y"), $1" >> ~/logs/failed_versioning.log
	fi
	echo "$2"
}