package internal

func Flatten(files ...string) ([]string, error) {
	bucket := make([]string, 0)
	for _, file := range files {
		blocks, err := Blocks(file)
		if err != nil {
			return nil, err
		}
		bucket = append(bucket, blocks...)
	}
	return bucket, nil
}
