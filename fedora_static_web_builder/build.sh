#!/bin/bash
# config
#PLUGIN_BUILDER
#PLUGIN_VHOST
#PLUGIN_USER

set -e
BASE_URL="https://${PLUGIN_VHOST}"

export PATH="$PATH:/usr/local/bin:/usr/local/sbin"

DEBUG_OPTION=""
if [ -v PLUGIN_DEBUG_BUILD ]; then
	set -x
	env | sort
	DEBUG_OPTION="-d"
	ip a
	ip r
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

	echo "set sftp:auto-confirm yes" > ~/.lftprc
	if [ -z "$SSH_KEY" ]; then
		KEY_OPTION=""
	else
		KEYFILE=/tmp/ssh_key
		# keep the double ${} for variable escaping, and the " for
		# https://stackoverflow.com/questions/22101778/how-to-preserve-line-breaks-when-storing-command-output-to-a-variable
		echo "${SSH_KEY}" > $KEYFILE
		chmod 700 $KEYFILE
		echo "set sftp:connect-program \"ssh -a -x -i $KEYFILE\"" >> ~/.lftprc
		if [ -v PLUGIN_DEBUG_BUILD ]; then
			md5sum /tmp/ssh_key
		fi;

	fi;
	# TODO deal with $SSH_PASS not defined if later we make the script more strict
	# TODO add -e once it work fine
	# TODO add -v if $DEBUG_OPTION is set
	# note: having a final / or not in the destination do not seems to have much impact, contrary to what is said in the changelog
	lftp $DEBUG_OPTION -u $PLUGIN_USER,$SSH_PASS -e "mirror -R --no-perms $BUILT_SITE/ $PLUGIN_DESTINATION_DIR; bye" sftp://$PLUGIN_SERVER
fi;
