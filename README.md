# lurker

Lurker is a simple bash script that recursively monitors a directory and executes a user-defined command when the directory content changes. Lurker is somewhat similar to tools like [grunt-watch](https://github.com/gruntjs/grunt-contrib-watch), but much much simpler and probably less oppinionated.

We use Lurker to dynamically build and run our [Go](http://golang.org/) microservices, locally on our development machines as well as inside [Docker](http://www.docker.com) containers on our test and integration servers.

Lurker uses the excellent [fswatch](http://emcrisostomo.github.io/fswatch/) tool (it's really just a wrapper around it) for monitoring changes in a directory and it works on Linux and OS X.

![The lurker in action...](https://raw.githubusercontent.com/codewerft/lurker/gh-pages/screenshot.png "The lurker in action...")

## Installation

Grab the latest release directly from Github: https://github.com/codewerft/lurker/releases

Unpack the archive, set the executable permissions for the shell script (``chmod +x lurker.sh``) and off yer go. If you want to make lurker available globablly, you can copy it to ``/usr/local/bin`` or any other directory in your ``$PATH``.

> **NOTE**: Lurker will fail if fswatch is not installed.
>
> *On OS X:*
>
> ```
> brew install fswatch
> ```
>
> *On Linux:*
>
> Build from source. Here are the [Instructions](http://emcrisostomo.github.io/fswatch/).

## Usage

> **NOTE**: ``lurker.sh -h`` gives you the full list of command-line options.

Here's a simple example showing how to use lurker to build and run a go web service whenever a file changes in the ``./src`` directory:

```
./lurker.sh -d ./src -e 'bin\|pkg\|\.git/' -t -c 'go run'
```

In the example above, ``go run`` never returns as it builds and starts a web service. We use the ``-t`` flag to instruct lurker to terminate the previous instance of ``go run`` before executing a new one. The ``-e`` flag tells lurker to ignore changes in the `.git/`, `pkg/`, and `bin/` directories.

## Changelog

### 0.2 - April 03. 2015

* Fix for exclude pattern handling.


### 0.1 - April 02. 2015

* First public release of lurker, tested on Linux and OS X.
