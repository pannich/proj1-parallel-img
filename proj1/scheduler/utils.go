package scheduler

import (
	"bufio"
	"encoding/json"
	"os"
	"strings"
	"fmt"
	"path/filepath"
)

func SetTaskPath(task *ImageTask, data_dir string) {
	// Set input output path
	task.InPath = filepath.Join("../data/in", data_dir, task.InPath)		// create inputpath .png

	// Create new outpath name
	outFilename := filepath.Base(task.OutPath)
	newOutFilename := fmt.Sprintf("%s_%s", data_dir, outFilename)
	task.OutPath = filepath.Join("../data/out", newOutFilename)		// create inputpath .png
}

func ReadTasksToQueue(effectsPathFile string, strDirs string) (*Queue, error) {
	effectsFile, err := os.Open(effectsPathFile)   // open file readonly mode
	if err != nil {
			return nil, err
	}
	defer effectsFile.Close()

	queue := NewQueue() // Your queue implementation

	// loop over queue to add big/ .. small/ variations
	dataDirs := strings.Split(strDirs, "+")


	for _, data_dir := range dataDirs {
		// Reset the file pointer to the beginning of the file before each scan
		if _, err := effectsFile.Seek(0, 0); err != nil {
			fmt.Println("Error seeking file:", err)
			return nil, err
		}

		scanner := bufio.NewScanner(effectsFile)			// Read line by line
		for scanner.Scan() {
			var task ImageTask
			err := json.Unmarshal(scanner.Bytes(), &task)			// Unmarshal takes in []byte slice and copy into &task struct
			if err != nil {
					return nil, err  // Handle the error appropriately
			}
			SetTaskPath(&task, data_dir)
			queue.Enqueue(task)
			}

		// Check if there were any errors during scanning
		if err := scanner.Err(); err != nil {
			return nil, err
			}
		}

	return queue, nil
}


// For debugging compare code
			// expectedImg, err := png.Load(filepath.Join("../data/expected", outFilename))
			// if err != nil {
			// 	panic(err)
			// }
