# lurker

Lurker is a simple bash script that recursively monitors a directory and
executes a user-defined command when the directory content changes. Lurker is 
somewhat similar to tools like [grunt-watch](https://github.com/gruntjs/grunt-contrib-watch),
but much much simpler and probably less oppinionated.

At Codewerft we use Lurker to dynamically build and run our  
[Go](http://golang.org/) microservices, locally on our Desktops as well as 
inside [Docker](http://www.docker.com) containers on our 
test and integration servers.

Lurker uses the excellent [fswatch](https://github.com/emcrisostomo/fswatch)
tool (it's really just a wrapper around it) for monitoring changes in a directory 
and it works on Linux and OS X.

![The lurker in action...](https://raw.githubusercontent.com/codewerft/lurker/gh-pages/screenshot.png "The lurker in action...")

## Installation

Grab the latest release directly from Github:

```bash
wget https://raw.githubusercontent.com/codewerft/lurker/release/lurker.sh
chmod +x lurker.sh
```

Lurker will fail if fswatch is not installed.

**On OS X:**

```
brew install fswatch
```

**On Linux:**

Build from source. Here are the [Instructions](https://github.com/emcrisostomo/fswatch/blob/master/INSTALL).

## Usage

This is a simple example how to use lurker to build and run a go web service
whenever something changes in the ``./src`` directory:

```
./lurker.sh -d ./src -t -c "go run"
```

The above example uses the ``-t`` flag because ``go run`` builds and starts a non-returning web service. The ``-t`` flag instructs lurker to termiante the previous instance of ``go run`` before executing a new one.
