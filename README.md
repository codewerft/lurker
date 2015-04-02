# lurker

Lurker is a simple bash script that recursively monitors a directory and
executes a user-defined command when the directory content changes. Probably
some of the more useful things about Lurker are:

 * Simplicity. It's really simple.
 * Not very oppinionated.
 * Supports blocking, infinitely running commands.

Lurker uses the excellent [fswatch](https://github.com/emcrisostomo/fswatch)
tool for monitoring changes in a directory and it works on Linux and OS X.

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

This is a simple example how to lurker to build and run a go web service:

```
./lurker.sh -d . -t -c "go run"
```

The above example uses the ``-t`` flag because ``go run`` builds and starts a non-returning web service. The ``-t`` flag instructs lurker to termiante the previous instance of ``go run`` before executing a new one.
