#!/bin/bash
# set -e

# if [ ! $ASCIINEMA_TOKEN ]; then
# 	echo 'Please set ASCIINEMA_TOKEN'
# 	exit 1
# fi
# mkdir -p ~/.config/asciinema/
# echo '[api]' > ~/.config/asciinema/config
# echo "token = $ASCIINEMA_TOKEN" >> ~/.config/asciinema/config


function Trap() {
	TIMEOUT=30
	while [ $TIMEOUT -gt 0 ]; do
		if screen -ls; then
			echo "There is a running processes left: `ps ax | grep 'asciinema rec' | grep -v grep | grep -v SCREEN | wc -l`. Timeout is $TIMEOUT seconds..."
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
	if ! screen -list | grep -q "$1"; then
		screen -S ${1} -d -m /usr/local/bin/asciinema rec -y -c "docker attach --no-stdin $1" /records/record-${1}.json
		echo "Started record for ${1}"
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