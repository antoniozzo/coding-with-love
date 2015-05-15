#!/usr/bin/env bash
 
echo "Updating server.."
sudo apt-get update
sudo apt-get install python-software-properties
sudo apt-get install jq

echo "Setting environment variables.."
ENV is "local"
DOMAIN is $1