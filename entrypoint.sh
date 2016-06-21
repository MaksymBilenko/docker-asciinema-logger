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

case $1 in
	'')
	/usr/local/bin/asciinema rec -y -t "${USERNAME}_${DOCKER_CONTAINER}" -w 1 -c "docker attach ${DOCKER_CONTAINER}"
	;;
	*)
	exec "$@"
	;;
esac