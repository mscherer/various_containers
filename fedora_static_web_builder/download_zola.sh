#!/bin/bash
set -e


NAME=zola
REPO=getzola/${NAME}
VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq .name | tr -d '"')
VERSION="v0.16.1"
TARBALL=${NAME}-${VERSION}-x86_64-unknown-linux-gnu.tar.gz

TMPFILE=/tmp/${NAME}.tar.gz
echo "Downloading $NAME $VERSION"

curl -s -L https://github.com/${REPO}/releases/download/${VERSION}/${TARBALL} --output $TMPFILE

cd /usr/local/bin ; tar -xf $TMPFILE
rm -f $TMPFILE
