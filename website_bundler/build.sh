#!/bin/bash
# config
# $PLUGIN_USER
# $PLUGIN_REGISTRY
# $PLUGIN_NAMESPACE
# $PLUGIN_PATH
set -e

if [ -z "$PASSWORD" ]; then
	echo "Variable \$PASWWORD not set, can't continue"
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

if [ -v PLUGIN_DEBUG_BUILD ]; then
	set -x
	env | sort
fi;

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
