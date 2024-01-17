package main

import (
	"os"
	"path"
	"strings"

	"github.com/vedadiyan/autosql/internal"
)

func main() {
	files, err := internal.ReadDir(path.Dir(os.Args[0]))
	if err != nil {
		panic(err)
	}
	blocks, err := internal.Flatten(files...)
	if err != nil {
		panic(err)
	}
	ordered, err := internal.Order(blocks)
	if err != nil {
		panic(err)
	}
	joined := strings.Join(ordered, "\r\n")
	os.WriteFile("script.sql", []byte(joined), os.ModePerm)
}
