# Template for Building Basic CLIs with Golang

The template offers the basic structure for building CLIs using Golang. 
It depends on three packages:
* Zap for logging
* Viper for configuration (though the template code is not making use of it)
* Cobra for the command interface

## Quick Instructions
1. Clone the project and copy it as a base for your cool new CLI. 
2. Adjust the values in the [`MANIFEST`](MANIFEST) file. 
3. Run `make init`; this will update your `.gitignore` and create a `Dockerfile` based on the values in the [`MANIFEST`](MANIFEST) file. 
4. Run either of
  * `make go-build` to build a binary file under the `bin` directory; check it out 
  * `make docker-build` to build an executable docker image; you can run the image by calling `make docker-run`
5. Start building your awesome CLI based on it. 

## Requirements
* Go version 1.17+
* GNU Make
* Git
* Docker (optional)
* Basic command-line tools: `sed`, `head`, `date`, `uname`, etc.

## Makefile Targets
Here are a subset of the Makefile targets worthy of a note; the rest you can figure out by diving 
into the [`Makefile`](Makefile) file. 
* `init`: initializes the repo by ensuring the existence of `.gitignore` file and building a `Dockerfile` based on [`Dockerfile.template`](Dockerfile.template)
* `go-mod`: tidies up and verifies the module info and presence of the dependencies
* `go-[lint|test]`: do their job as expected 
* `go-build`: builds a binary depending on the OS (not sure if the distinction is really needed)
* `docker-[clean|build|run]`: do their docker magic as their names imply

