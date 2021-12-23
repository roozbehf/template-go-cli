package main

import (
	"github.com/roozbehf/template-go-cli/cmd"
	"github.com/roozbehf/template-go-cli/internal/log"
)

func main() {
	defer log.Flush()

	cmd.Execute()
}
