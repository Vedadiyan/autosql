package test

import (
	"os"
	"strings"
	"testing"

	"github.com/vedadiyan/autosql/internal"
)

func TestBlocks(t *testing.T) {
	files, err := internal.ReadDir("cases")
	if err != nil {
		t.FailNow()
	}
	blocks, err := internal.Flatten(files...)
	if err != nil {
		t.FailNow()
	}
	ordered, err := internal.Order(blocks)
	if err != nil {
		t.FailNow()
	}
	joined := strings.Join(ordered, "\r\n")
	os.WriteFile("test.sql", []byte(joined), os.ModePerm)
	_ = ordered
}
