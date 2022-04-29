#!/bin/bash
# config
#PLUGIN_BUILDER
#PLUGIN_SERVER
#PLUGIN_VHOST
#PLUGIN_USER
#PLUGIN_SSH_KEY
#PLUGIN_DESTINATION_DIR

BASE_URL="//${PLUGIN_VHOST}"
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

eval $CMD $CMD_DRAFT $CMD_BASE_URL

KEYFILE=/tmp/ssh_key
# keep the double ${} for variable escaping, and the " for
# https://stackoverflow.com/questions/22101778/how-to-preserve-line-breaks-when-storing-command-output-to-a-variable
echo "${SSH_KEY}" > $KEYFILE
chmod 700 $KEYFILE

scp -o 'StrictHostKeyChecking no' -r -i $KEYFILE $BUILT_SITE/* $PLUGIN_USER@$PLUGIN_SERVER:$PLUGIN_DESTINATION_DIR
