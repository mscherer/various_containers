#!/bin/bash
# config
# $PLUGIN_USER
# $PLUGIN_REGISTRY
# $PLUGIN_NAMESPACE
# $PLUGIN_PATH
# $PLUGIN_NAME
set -e
if [ -v PLUGIN_DEBUG_BUILD ]; then
	set -x
	env | sort
fi;


if [ -z "$PASSWORD" ]; then
	echo "Variable \$PASSWORD not set, can't continue"
	exit 1
fi

if [ -v PLUGIN_USER ]; then
	USER=nologin
else
	USER=$PLUGIN_USER
fi

FORMAT=""
if [ -v "$PLUGIN_MANIFEST_TYPE" ]; then
	FORMAT="--format $PLUGIN_MANIFEST_TYPE"
fi;

REGISTRY=$PLUGIN_REGISTRY

NAMESPACE=""
if [ -v PLUGIN_NAMESPACE ]; then
	NAMESPACE="/$PLUGIN_NAMESPACE"
fi;

NAME=webserver
if [ -v PLUGIN_NAME ]; then
	NAME="$PLUGIN_NAME"
fi;

# TODO guess the directory for non zola/hugo
if [ -v PLUGIN_PATH ]; then
	SITE_PATH=${CI_WORKSPACE}/public
else
	SITE_PATH=${CI_WORKSPACE}/$PLUGIN_PATH
fi

# compile in /tmp, if container is readonly
cd /tmp

cp -R $SITE_PATH public

# this script must produce a file /tmp/server, used
# later to build the container
bash /usr/local/bin/build.local.sh
# safeguard in case a script forget to come back to /tmp
cd /tmp
if [ ! -f server ]; then
	echo "No server found in $(pwd), can't continue"
fi;

# to avoid error:
# 'overlay' is not supported over overlayfs, a mount_program is required: backing file system is unsupported for this graph driver
CMD="buildah --storage-driver vfs"
# build the container
$CMD bud -t $NAME:latest .

# send to the registry
echo $PASSWORD | $CMD login -u $USER --password-stdin $REGISTRY
$CMD tag $NAME:latest ${REGISTRY}${NAMESPACE}/$NAME:latest
$CMD push $FORMAT ${REGISTRY}${NAMESPACE}/$NAME:latest
