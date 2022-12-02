#!/bin/bash
cp -r /srv/rust-static-server .
cp /srv/Dockerfile .
cd rust-static-server
ln ../public .
# run the build.sh from the git repository, who compress data
bash ./build.sh
mv target/x86_64-unknown-linux-gnu/release/static_http ../server
cd ..
