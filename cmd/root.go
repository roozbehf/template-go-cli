package cmd

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var configFile string

var ExecutableFileName = "go-cli"
var GitRevision = ""
var BuildVersion = ""
var BuildTime = ""

const (
	CF_Config_Dir = "config-dir"

	EnvVarPrefix = "ROOZ_CLI"
)

var rootCmd = &cobra.Command{
	Use:     ExecutableFileName,
	Version: fmt.Sprintf("%s (Build time: %s, Repository revision: %s)", BuildVersion, BuildTime, GitRevision),
	Short:   "a go cli example",
	Long:    ``,
	RunE:    doIt,
}

// Execute executes the root command
func Execute() {
	failOnError(rootCmd.Execute())
}

// doIt does the main task of this CLI's root command
func doIt(cmd *cobra.Command, args []string) error {
	fmt.Println("Hello Universe!")
	return nil
}

func failOnError(err error) {
	if err != nil {
		// TODO introduce a logging flag
		// log.Error("failed", log.LK_Error, err.Error())
		rootCmd.Usage()
		os.Exit(1)
	}
}

func init() {
	viper.SetEnvPrefix(EnvVarPrefix)
	replacer := strings.NewReplacer(".", "_")
	viper.SetEnvKeyReplacer(replacer)

	viper.AutomaticEnv()

	rootCmd.SilenceErrors = false
	rootCmd.SilenceUsage = true
}
