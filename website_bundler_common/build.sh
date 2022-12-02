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

FORMAT=""
USER=""
NAME=""
NAMESPACE=""

if [ -v PLUGIN_REGISTRY ]; then
	REGISTRY=$PLUGIN_REGISTRY
else
	if [ -f fly.toml ]; then
		REGISTRY="registry.fly.io"
	else
		echo "No registry given, can't continue"
		exit 1
	fi
fi


if [ "$REGISTRY" == "registry.fly.io" ]; then
	USER="x"
	FORMAT="--format v2s2" 
	if [ -f fly.toml ]; then
		NAME=$(grep ^app fly.toml | awk -F '"' '{print $2}')
	fi
elif [ "$PLUGIN_REGISTRY" == "*.scw.cloud" ]; then
	USER=nologin
fi


if [ -v PLUGIN_USER ]; then
	USER=$PLUGIN_USER
fi

if [ -v PLUGIN_MANIFEST_TYPE ]; then
	FORMAT="--format $PLUGIN_MANIFEST_TYPE"
fi;

if [ -v PLUGIN_NAMESPACE ]; then
	NAMESPACE="/$PLUGIN_NAMESPACE"
fi;

if [ -v PLUGIN_NAME ]; then
	NAME="$PLUGIN_NAME"
fi;

# TODO guess the directory for non zola/hugo
if [ -v PLUGIN_PATH ]; then
	SITE_PATH=${CI_WORKSPACE}/$PLUGIN_PATH
else
	SITE_PATH=${CI_WORKSPACE}/public
fi

if [ -z "$USER" ]; then
	echo "No user given (or detected), can't login to registry"
	exit 1
fi

if [ -z "$NAME" ]; then
	echo "No container name given (or detected), can't push to registry"
	exit 1
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
