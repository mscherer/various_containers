#!/bin/bash

echo "#!/bin/sh" > server
echo "cd /tmp" >> server
echo "cat << EOF | base64 -d | gzip -d | tar -x -f -" >> server
( cd public ; tar -c . -f - | gzip | base64 ) >> server
echo "EOF" >> server
echo "busybox httpd -p \${PORT:-8080}" >> server

chmod +x server
