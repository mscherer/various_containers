#!/bin/bash
# config
#PLUGIN_BUILDER
#PLUGIN_VHOST
#PLUGIN_USER

set -e
BASE_URL="//${PLUGIN_VHOST}"

if [ -v PLUGIN_DEBUG_BUILD ]; then
	set -x
	env
fi;
	       

if [ -z "$PLUGIN_BUILDER" ]; then
	if [ -f config.toml ]; then
		if grep -q languageCode config.toml ; then
			PLUGIN_BUILDER=hugo
		fi;
		if grep -q default_language config.toml ; then
			PLUGIN_BUILDER=zola
		fi; 
	fi;
fi;

case $PLUGIN_BUILDER in
	zola)
		CMD="zola build"
		CMD_DRAFT="--drafts"
	       	CMD_BASE_URL="--base-url $BASE_URL"
		BUILT_SITE="public"
	;;
	hugo)
		CMD="hugo" 
		CMD_DRAFT="-D"
		CMD_BASE_URL="--baseURL $BASE_URL"
		BUILT_SITE="public"
	;;		
esac

if [ -z "$PLUGIN_DRAFT" ]; then
	CMD_DRAFT=""
fi;

if [ -z "$CMD" ]; then
	echo "No supported static website builder specified or detected, got $PLUGIN_BUILDER"
	exit 1
fi;

eval $CMD $CMD_DRAFT $CMD_BASE_URL

if [ -z "$PLUGIN_CHECK" ]; then
	if [ -z "$PLUGIN_SERVER" ]; then
		PLUGIN_SERVER=${PLUGIN_VHOST}
	fi;

	if [ -z "$PLUGIN_DESTINATION_DIR" ]; then
		PLUGIN_DESTINATION_DIR="/var/www/${PLUGIN_VHOST}"
	fi;

	if [ -z "$SSH_KEY" ]; then
		KEY_OPTION=""
	else
		KEYFILE=/tmp/ssh_key
		# keep the double ${} for variable escaping, and the " for
		# https://stackoverflow.com/questions/22101778/how-to-preserve-line-breaks-when-storing-command-output-to-a-variable
		echo "${SSH_KEY}" > $KEYFILE
		chmod 700 $KEYFILE
		KEY_OPTION="-i $KEYFILE"
	fi;
	if [ -z "$SSH_PASS" ]; then
	        SSHPASS_CMD=""
	else
		# TODO escape if need arise
		SSHPASS_CMD="sshpass -p \"$SSH_PASS\""
	fi;

	$SSHPASS_CMD scp -o 'StrictHostKeyChecking no' -r $KEY_OPTION $BUILT_SITE/* $PLUGIN_USER@$PLUGIN_SERVER:$PLUGIN_DESTINATION_DIR
fi;
