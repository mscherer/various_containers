cp /srv/rust-static-server .
cp /srv/Dockerfile .
cd rust-static-server
ln ../public .
bash build.sh 
mv target/x86_64-unknown-linux-gnu/release/static_http ../server
cd ..
