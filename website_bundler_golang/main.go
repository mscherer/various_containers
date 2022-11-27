package main

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
	"os"
)

var (
	//go:embed public/*
	static_files embed.FS
)

func main() {
	// https://stackoverflow.com/questions/66365902/go-1-16-embed-strip-directory-name
	sub_dir, err := fs.Sub(static_files, "public")
	if err != nil {
		panic(err)
	}

	port, isPortSet := os.LookupEnv("PORT")
	if !isPortSet {
		port = "8088"
	}

	http.Handle("/", http.FileServer(http.FS(sub_dir)))

	err = http.ListenAndServe(":"+port, nil)
	if err != nil {
		panic(err)
	}
	log.Println("server started on port " + port)
}
