cp /srv/main.go /srv/Dockerfile .
# CGO prevent static build, needed for scratch container
# https://words.filippo.io/shrink-your-go-binaries-with-this-one-weird-trick/
CGO_ENABLED=0 go build -ldflags "-s -w" main.go
mv main server
