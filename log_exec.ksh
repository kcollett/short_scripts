#!/bin/ksh

# log_exec -- generic function for logging and executing commands

[ "$LE_PRINT_ONLY" ] && print_only=1 || print_only=0
[ "$1" = "-n" ] && { print_only=1; shift; } || print_only=0

[ $# -lt 2 ] && \
    { echo "usage: $0 [-n] {<logfile>|-} <command> [<arg> ...]" >&2;
      exit 1; }
logfile="$1"; shift

# execute command only if PRINTONLY is not yes-like
if [ $print_only -ne 1 ]
then
    # output command to stdout, and to $logfile if not stdout
    echo "$@" >&2
    [ "$logfile" != "-" ] && echo "$@" >>$logfile

    [ "$logfile" = "-" ] && eval "$@" || { eval "$@" >>$logfile 2>&1; }
    retval=$?
else
    # output command to stdout, and to $logfile if not stdout
    echo ": $@"
    [ "$logfile" != "-" ] && echo ": $@" >>$logfile

    : "I do nuting!"
    retval=0
fi

exit $retval
