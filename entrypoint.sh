#!/bin/bash
# set -e

if [ ! $ASCIINEMA_TOKEN ]; then
	echo 'Please set ASCIINEMA_TOKEN'
	exit 1
fi

mkdir -p ~/.config/asciinema/
echo '[api]' > ~/.config/asciinema/config
echo "token = $ASCIINEMA_TOKEN" >> ~/.config/asciinema/config
if [ $API_URL ]; then
	echo "url = $API_URL" >> ~/.config/asciinema/config
fi


function Trap() {
	TIMEOUT=30
	while [ $TIMEOUT -gt 0 ]; do
		if tmux ls; then
			echo "There is a running processes left: `tmux ls 2>/dev/null | wc -l`. Timeout is $TIMEOUT seconds..."
			sleep 5
			TIMEOUT=$((TIMEOUT - 5))
		else
			TIMEOUT=0
		fi
	done
	touch /tmp/stop_container
}

trap Trap SIGTERM SIGINT SIGHUP

function start_record {
	if ! tmux ls | grep -q "$1"; then
		tmux new -d -s ${1} "/usr/local/bin/asciinema rec -y -t '${HOSTNAME}_${1}' -w 1 -c 'docker attach $1'"
		echo "Started record for ${1} with name: ${HOSTNAME}_${1}"
	fi
}

function asciinema_loop {
	RUNNING=''
	while [ ! -f /tmp/stop_container ]; do
		DOCKER_PS_NAMES=`docker ps --format {{.Names}}`
		for container in $DOCKER_PS_NAMES; do
			start_record $container
		done
		sleep 5
	done
}

case $1 in
	'')
	asciinema_loop
	;;
	*)
	exec "$@"
	;;
esac