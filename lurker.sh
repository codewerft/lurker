#!/bin/bash -l

# Copyright (C) 2015 Codewerft Flensburg (http://www.codewerft.net)
# Licensed under the MIT License

# -----------------------------------------------------------------------------
# Global variables
#
SCRIPTNAME=`basename $0`
SCRIPTVERSION=0.1
WATCH_DIR=
EXCLUDE=0
COMMAND=
ACTIVE_PID=0

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

$SCRIPTNAME recursively monitors a directory for changes and executes a
user-defined command if a change was detected.

OPTIONS:

   -d DIR      Watch DIR for changes

   -e REGEX    Exclude paths matching REGEX

   -c COMMAND  Execute COMMAND after a change was detected

   -t          Try to terminate the previous instance of COMMAND before running it again

   -v          Print the version of $SCRIPTNAME and exit.

   -h          Show this message


EXAMPLES:

  Watch for changes in the current directory and

$SCRIPTNAME.sh -d . -c "go run"


EOF
}

# -----------------------------------------------------------------------------
# Script entry point
#

# make sure fswatch is installed, exit with error if not
fswatch --version >/dev/null 2>&1 || {
    echo >&2 -e "$CLR_ERROR$SCRIPTNAME requires fswatch but it's not installed. Aborting.$CLR_RESET";
    echo >&2 -e "\nOn OS X install fswatch with 'brew install fswatch'.";
    echo >&2 -e "On Linux install fswatch with 'xyz'.\n";
    exit 1;
}

while getopts hvkd:c:e: OPTION
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
        k)
            KILL=true
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

# The main loop, watching for changes, reacting to them
while true
do
    # Watch out for changes. fswatch blocks until it sees a change
    echo -e "$CLR_OK$(log_prefix) watching $WATCH_DIR for changes$CLR_RESET" >&2
    if [ $EXCLUDE -ne 0 ]; then
        CHANGE=`fswatch --recursive --one-event --exclude $EXCLUDE $WATCH_DIR`
    else
        CHANGE=`fswatch --recursive --one-event $WATCH_DIR`
    fi
    echo -e "$CLR_CHANGE$(log_prefix) change detected in $CHANGE$CLR_RESET" >&2

    # Kill the previous command (if there was one), report on the results
    if [ $ACTIVE_PID -ne 0 ]; then
        if ! kill -TERM $ACTIVE_PID > /dev/null 2>&1; then
          echo -e "$CLR_WARNING$(log_prefix) couldn't terminate process with pid $ACTIVE_PID (already dead)$CLR_RESET" >&2
        else
          echo -e "$CLR_OK$(log_prefix) successfully terminated process with pid $ACTIVE_PID$CLR_RESET" >&2
        fi
    fi

    # Launch the 'command', record the pid
    $COMMAND > /dev/null 2>&1  &
    ACTIVE_PID=$!
    echo -e "$CLR_OK$(log_prefix) launched command '$COMMAND' with pid $ACTIVE_PID$CLR_RESET" >&2

done



# # Construct the Git checkout URL.
# CHECKOUT_URL=$REPOSITORY_URL
# if ! [[ -z $TOKEN ]] ; then
#     CHECKOUT_URL=`echo $REPOSITORY_URL | sed -e "s/:\/\//\:\/\/$TOKEN@/g"`
# fi
#
# # Make sure the checkout dir exists and we have write permission.
# if ! [[ -d "$CHECKOUT_DIR" ]] ; then
#   # Control will enter here if $DIRECTORY doesn't exist.
#   echo " * Creating checkout directory $CHECKOUT_DIR"
#   mkdir -p $CHECKOUT_DIR
# fi
#
# # Change into working directory and check if it is a valid git repository.
# cd $CHECKOUT_DIR
# git status
# if [[ $? != 0 ]] ; then
#     # It is not. Clone the repository.
#     git clone -b $BRANCH $CHECKOUT_URL .
# fi
#
# for (( ; ; ))
# do
#     # Update the repository
#     printf " * Updating repository (git pull)"
#     git pull
#     if [[ $? != 0 ]] ; then
#         # Git command failed.
#         printf " [FAILED]\n"
#     else
#         printf " [OK]\n"
#     fi
#
#     # Run the build command
#     printf " * Building repository ($BUILD_COMMAND)"
#     $BUILD_COMMAND
#     if [[ $? != 0 ]] ; then
#         # Build command failed.
#         printf " [FAILED]\n"
#     else
#         printf " [OK]\n"
#     fi
#
#     # Slee until the next interval
#     sleep $UPDATE_INTERVAL
# done

exit 0
