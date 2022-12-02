#!/bin/bash
cp -r /srv/rust-static-server .
cd rust-static-server
ln -s ../public .
# run the build.sh from the git repository, who compress data
bash ./build.sh
mv target/x86_64-unknown-linux-gnu/release/static_http ../server
cd ..
