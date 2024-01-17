package internal

import (
	"bytes"
	"fmt"
	"os"
	"strings"
)

func Blocks(file string) ([]string, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}
	return GetBlocks(data)
}

func GetBlocks(data []byte) ([]string, error) {
	var buffer bytes.Buffer
	out := make([]string, 0)

	hold := false
	blockHold := false
	for i := 0; i < len(data); i++ {
		r := rune(data[i])

		switch r {
		case '\\':
			{
				buffer.WriteRune(r)
				if len(data) <= i+1 {
					return nil, fmt.Errorf("invalid escape character at the end of the string")
				}
				buffer.WriteRune(rune(data[i+1]))
				i++
				continue
			}
		case '"':
			{
				hold = !hold
			}
		case '$':
			{
				if len(data) > i+1 {
					if rune(data[i+1]) == '$' {
						blockHold = !blockHold
					}
				}
			}
		}
		buffer.WriteRune(r)
		if !hold && !blockHold && r == ';' {
			out = append(out, strings.TrimLeft(strings.TrimLeft(buffer.String(), "\r\n"), " "))
			buffer.Reset()
		}
	}
	if buffer.Len() > 0 {
		value := strings.TrimLeft(strings.TrimLeft(buffer.String(), "\r\n"), " ")
		if len(value) > 0 {
			out = append(out, value)
		}
		buffer.Reset()
	}
	return out, nil
}
