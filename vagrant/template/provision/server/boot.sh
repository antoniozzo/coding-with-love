#!/usr/bin/env bash
 
if [ -f $1/composer.json ]; then
	echo "Installing composer packages.."
	cd $1; composer update --prefer-dist
fi
