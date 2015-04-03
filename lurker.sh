#!/bin/bash -l

# Copyright (C) 2015 Codewerft Flensburg (http://www.codewerft.net)
# Licensed under the MIT License

# -----------------------------------------------------------------------------
# Global variables
#
SCRIPTNAME=`basename $0`
SCRIPTVERSION=0.2
WATCH_DIR=
EXCLUDE=""
COMMAND=
ACTIVE_PID=0
TERMINATE=0

# -----------------------------------------------------------------------------
# Some ANSI color definitions
#
CLR_ERROR='\033[0;31m'
CLR_WARNING='\033[0;33m'
CLR_OK='\033[0;32m'
CLR_CHANGE='\033[0;35m'
CLR_RESET='\033[0m'

# -----------------------------------------------------------------------------
# Print version of this tool
#
version()
{
  echo -e "\n$SCRIPTNAME $SCRIPTVERSION\n"
  echo -e "Copyright (C) 2015 Codewerft Flensburg (http://www.codewerft.net)"
  echo -e "Licensed under the MIT License\n"
  echo -e "This is free software: you are free to change and redistribute it."
  echo -e "There is NO WARRANTY, to the extent permitted by law.\n"
}

# -----------------------------------------------------------------------------
# Print the log prefix consisting of timestamp and scriptname
#
log_prefix()
{
  echo "[$(date +"%d/%b/%Y:%H:%M:%S %z")] $SCRIPTNAME:"
}

# -----------------------------------------------------------------------------
# Print script usage help
#
usage()
{

cat << EOF
usage: $SCRIPTNAME options

$SCRIPTNAME is a simple bash script that recursively monitors a directory and
executes a user-defined command when the directory content changes.

OPTIONS:

   -d DIR      Watch DIR for changes

   -e REGEX    Exclude paths matching REGEX

   -c COMMAND  Execute COMMAND after a change was detected

   -t          Try to terminate the previous instance of COMMAND before running it again

   -v          Print the version of $SCRIPTNAME and exit.

   -h          Show this message


EXAMPLES:

  Watch the source directory of a Go web serivce, build and run on change.

$SCRIPTNAME.sh -d ./src -t -c "go run"


EOF
}

# -----------------------------------------------------------------------------
# Launch the 'user command', set trap, record the pid
#
run_user_command()
{
  $COMMAND 2>&1 &
  ACTIVE_PID=$!
  trap "pkill -P $ACTIVE_PID; echo -e '$CLR_OK$(log_prefix) terminated all background processes on exit$CLR_RESET'; exit" SIGHUP SIGINT SIGTERM
  echo -e "$CLR_OK$(log_prefix) launched command '$COMMAND' with pid $ACTIVE_PID$CLR_RESET" >&2
}

# -----------------------------------------------------------------------------
# Terminate the 'user command'
#
terminate_user_command()
{
  # only if the -t flag was provided
  if [ $TERMINATE -ne 0 ]; then
    if [ $ACTIVE_PID -ne 0 ]; then
      if ! pkill -P $ACTIVE_PID > /dev/null 2>&1; then
        echo -e "$CLR_WARNING$(log_prefix) couldn't terminate process with pid $ACTIVE_PID (already dead)$CLR_RESET" >&2
      else
        echo -e "$CLR_OK$(log_prefix) successfully terminated process with pid $ACTIVE_PID$CLR_RESET" >&2
      fi
    fi
  fi
}

# -----------------------------------------------------------------------------
# MAIN - Script entry point
#

# make sure fswatch is installed, exit with error if not
fswatch --version >/dev/null 2>&1 || {
    echo >&2 -e "$CLR_ERROR$SCRIPTNAME requires fswatch but it's not installed. Aborting.$CLR_RESET";
    echo >&2 -e "\nOn OS X install fswatch with 'brew install fswatch'.";
    echo >&2 -e "On Linux install fswatch with 'xyz'.\n";
    exit 1;
}

while getopts hvtkd:c:e: OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        v)
            version
            exit 0
            ;;
        e)
            EXCLUDE=$OPTARG
            ;;
        d)
            WATCH_DIR=$OPTARG
            ;;
        c)
            COMMAND=$OPTARG
            ;;
        t)
            TERMINATE=1
            ;;
        ?)
            usage
            exit
            ;;
     esac
done

# Make sure -d and -r were set
if [[ -z $WATCH_DIR ]] || [[ -z $COMMAND ]]
then
    usage
    exit 1
fi

# Launch the 'user command', record the pid
run_user_command

# The main loop, watching for changes, reacting to them
while true
do
    # Watch out for changes. fswatch blocks until it sees a change
    echo -e "$CLR_OK$(log_prefix) watching $WATCH_DIR for changes$CLR_RESET" >&2
    if [ -n $EXCLUDE ]; then
        CHANGE=`fswatch --recursive --one-event --exclude $EXCLUDE $WATCH_DIR`
    else
        CHANGE=`fswatch --recursive --one-event $WATCH_DIR`
    fi
    echo -e "$CLR_CHANGE$(log_prefix) change detected in $CHANGE$CLR_RESET" >&2

    # Kill the previous command (if there was one), report on the results
    terminate_user_command

    # Launch the 'user command', record the pid
    run_user_command

done
