#!/usr/bin/env bash
 
echo "Installing composer.."
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

json=$(cat <<EOF
{
	"name": "${1}",
	"description": "",
	"type": "project",
	"minimum-stability": "stable",
	"require": {
	}
}
EOF)

if [ ! -f $2/composer.json ]; then
	echo "${json}" > $2/composer.json
fi
