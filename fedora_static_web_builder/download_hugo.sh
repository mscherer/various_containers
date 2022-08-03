#!/bin/bash
set -e

NAME=hugo
REPO=gohugoio/${NAME}
VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq .name | tr -d '"')
TARBALL=${NAME}_${VERSION##v}_Linux-64bit.tar.gz

TMPFILE=/tmp/${NAME}.tar.gz
echo "Downloading $NAME $VERSION"

curl -s -L https://github.com/${REPO}/releases/download/${VERSION}/${TARBALL} --output $TMPFILE

cd /usr/local/bin ; tar -xf $TMPFILE
rm -f $TMPFILE
