#!/bin/bash
# config
# $PLUGIN_USER
# $PLUGIN_REGISTRY
# $PLUGIN_NAMESPACE
# $PLUGIN_PATH
set -e
if [ -v PLUGIN_DEBUG_BUILD ]; then
	set -x
	env | sort
fi;


if [ -z "$PASSWORD" ]; then
	echo "Variable \$PASSWORD not set, can't continue"
	exit 1
fi

if [ -z "$PLUGIN_USER" ]; then
	USER=nologin
else
	USER=$PLUGIN_USER
fi
REGISTRY=$PLUGIN_REGISTRY
NAMESPACE=$PLUGIN_NAMESPACE

NAME=webserver

# TODO guess the directory for non zola/hugo
if [ -z "$PLUGIN_PATH" ]; then
	SITE_PATH=$(pwd)/public
else
	SITE_PATH=$PLUGIN_PATH
fi

# compile in /tmp, if container is readonly
cd /tmp
cp -R $SITE_PATH public
./build.golang.sh

# to avoid error:
# 'overlay' is not supported over overlayfs, a mount_program is required: backing file system is unsupported for this graph driver
CMD="buildah --storage-driver vfs"
# build the container
$CMD bud -t $NAME:latest .

# send to the registry
echo $PASSWORD | $CMD login -u $USER --password-stdin $REGISTRY
$CMD tag $NAME:latest $REGISTRY/$NAMESPACE/$NAME:latest
$CMD push $REGISTRY/$NAMESPACE/$NAME:latest
