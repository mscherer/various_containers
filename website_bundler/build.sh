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

# to avoid error:
# 'overlay' is not supported over overlayfs, a mount_program is required: backing file system is unsupported for this graph driver
export STORAGE_DRIVE=vfs

# TODO guess the directory for non zola/hugo
if [ -z "$PLUGIN_PATH" ]; then
	SITE_PATH=$(pwd)/public
else
	SITE_PATH=$PLUGIN_PATH
fi

# compile in /tmp, if container is readonly
cd /tmp
cp -R $SITE_PATH public
cp /srv/main.go /srv/Dockerfile .
# CGO prevent static build, needed for scratch container
CGO_ENABLED=0 go build main.go

# build the container
buildah bud -t $NAME:latest .

# send to the registry
echo $PASSWORD | buildah login -u $USER --password-stdin $REGISTRY
buildah tag $NAME:latest $REGISTRY/$NAMESPACE/$NAME:latest
buildah push $REGISTRY/$NAMESPACE/$NAME:latest
