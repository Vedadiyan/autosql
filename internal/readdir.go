package internal

import (
	"fmt"
	"os"
	"strings"
)

func ReadDir(dir string) ([]string, error) {
	content, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	out := make([]string, 0)
	for _, item := range content {
		if item.IsDir() {
			res, err := ReadDir(fmt.Sprintf("%s/%s", dir, item.Name()))
			if err != nil {
				return nil, err
			}
			out = append(out, res...)
			continue
		}
		if !strings.HasSuffix(item.Name(), ".sql") {
			fmt.Println("skipped", item.Name())
			continue
		}
		out = append(out, fmt.Sprintf("%s/%s", dir, item.Name()))
	}
	return out, nil
}
