#!/bin/bash
REPO=getzola/zola
VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq .name | tr -d '"')
TMPFILE=/tmp/zola.tar.gz

echo "Downloading zola $VERSION"

curl -s -L https://github.com/$REPO/releases/download/$VERSION/zola-$VERSION-x86_64-unknown-linux-gnu.tar.gz --output $TMPFILE

tar -xf $TMPFILE /usr/local/bin/zola
rm -f $TMPFILE
