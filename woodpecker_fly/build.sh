#!/bin/bash
set -e
if [ ! -f fly.toml ]; then
	echo 'No fly.toml file found'
	exit 1
fi
if [ -z "$FLY_API_TOKEN" ]; then
	echo 'No access token provided, set a secret named fly_api_token'
	exit 1
fi

COMMAND="deploy"
if [ -v PLUGIN_COMMAND ]; then
	COMMAND="$PLUGIN_COMMAND"
fi

fly $COMMAND
