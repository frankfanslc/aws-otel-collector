package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"time"
)

func main() {
	replicas := 10
	metricLoad := 10
	region := "us-west-2"
	workspace := "ws-e5a220a3-733e-46dd-a6d5-5685c1800362"

	startTime := time.Now().UTC().Format(time.RFC3339)[:19] + ".000Z"

	// construct `sleep.sh` command
	cmd := &exec.Cmd{
		Path:   "./bash.sh",
		Args:   []string{"./bash.sh", "-r" + region, "-w" + workspace, "-p" + strconv.Itoa(replicas), "-m" + strconv.Itoa(metricLoad)},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
	}

	// run `cmd` in background
	cmd.Start()

	// wait `cmd` until it finishes
	cmd.Wait()

	fmt.Fprintln(os.Stdout)

	endTime := time.Now().UTC().Format(time.RFC3339)[:19] + ".000Z"

	// construct `sleep.sh` command
	destroyCmd := &exec.Cmd{
		Path:   "./destroy.sh",
		Args:   []string{"./destroy.sh", "-r" + region, "-w" + workspace, "-s" + startTime, "-e" + endTime, "-m" + strconv.Itoa(metricLoad)},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
	}

	// run `cmd` in background
	destroyCmd.Start()

	// wait `cmd` until it finishes
	destroyCmd.Wait()

	fmt.Fprintln(os.Stdout)
}
