# Various containers images

All those images are autoupdated on new Fedora version and release thanks to a cron job.

## Fedora static web builder 

As part of my personal CI, I use woodpecker and a Fedora container to build static
websites. In order to not lose time reinstalling the same 3 packages (cause 
that's 1.58 minutes over the total 2 minutes build of zola/hugo and scp/rsync), I
decided to create a container that do that once and for all, and automation
to keep it updated when a new fedora is released.

## Download test for Openshift 

To test the download speed from our Openshift cluster, I created a small image that just
serve a static file of 50 Mb. The size can be changed, see the code for details. The file can be found 
on /data using over http on the port configured on Openshift.

## Website bundler

This image will take a existing volume as a source, and create a container with a single go/rust static 
binary serving as a HTTP server. I will then push the container a to a remote registry, such as the one 
from Scaleway for their CaaS offer, or fly.io, if already configured.

Due to using a Fedora base image and choices made by Fedora, the Go project and Rust, the container used to build 
is quite big (eg, 800 Mb), either for go or rust.

## Fly woodpecker plugin

This image allow to use fly as a woodpecker step, by running `fly deploy` on the existing
CI. Used for fly.io hosting. 
