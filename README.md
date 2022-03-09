Quick autoupdating image to build static website

As part of my personal CI, I use woodpecker and Fedora container to build static
websites. In order to not lose time reinstalling the same 3 packages (cause 
that's 1.58 minutes over the total 2 minutes build of zola/hugo and scp/rsync), I
decided to create a container that do that once and for all, and automation
to keep it updated when a new fedora is released.
