#!/bin/bash
mkdir /tmp/html
dd of=/tmp/html/data if=/dev/urandom count=${SIZE:-102400}
/usr/bin/caddy file-server -listen :8080 -root /tmp/html/

