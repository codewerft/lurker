# lurker

Lurker is a simple bash script that recursively monitors a directory for changes
and executes a user-defined command if a change was detected.

Lurker uses the excellent [fswatch](https://github.com/emcrisostomo/fswatch)
tool for monitoring changes in a directory.

## Installation

Grab the latest release directly from Github:

```bash
wget https://raw.githubusercontent.com/codewerft/lurker/release/lurker.sh
chmod +x lurker.sh
```
