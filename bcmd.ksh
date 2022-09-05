#! /bin/ksh

usage()
{
    cat <<-EOF >&2

	bcmd [-log name] [-nohup|-nohupout|-noout] <command>

	Execute <commmand> with stdout and stderr copied to BCMD.LOG.

	If -noout is given, then produce no output to stdout or stderr.
	If -nohup option is given, nohup <command>.
	If -nohupout option is given, nohup <command> and return immediately.

	This table summarizes the behavior of bcmd:

				Synchronous	Asynchronous

		Output  	<default>	-nohup
		No Output	-noout		-nohupout
	EOF
    exit 1
}

true="t"
false=

prog=${0##*/}
typeset -u PROG="$prog"

wrttst="${PROG}tst.$$"

nohup=""
nohupout=""
noout=""
mode="normal"
log="$PROG.LOG"

while :
do
    case "$1" in
	-log)
	    (($# < 2)) && usage
	    log="$2.log"
	    shift
	    ;;
        -nohup)
	    nohup="nohup"
	    mode="nohup"
	    ;;
        -nohupout)
	    nohup="nohup"
	    nohupout="nohupout"
	    mode="nohupout"
	    ;;
	-noout)
	    noout="noout"
	    mode="noout"
	    ;;
	-h)
	    usage
	    ;;
       *)		# rest of args command to be logged
            break
	    ;;
    esac
    shift
done

#
# Check to see if we can create the logfile in the current directory,
# and if not, create the logfile in the user's home directory.  (I
# don't use "test -w ." because it only checks the directory's mode
# bits and doesn't check for a read-only filesystem.)
#
touch $wrttst 2>/dev/null && rm -f $wrttst || log="$HOME/$log"

# save last log if it exists
if [ -f $log ]
then
    integer top_log_num new_log_num
    ls -1 $log.* 2>/dev/null | cut -d'.' -f3 | sort -nr | read top_log_num
    [ "$top_log_num" ] || top_log_num=0
    ((new_log_num=$top_log_num + 1))
    new_log=$log.$new_log_num
    /bin/mv $log $new_log
fi

alias banner='echo "bcmd($mode): $@"; \
	      echo "Log: $log"; \
	      echo "System: \c"; uname -a; \
	      echo "Directory: \c"; pwd'

if [ "$nohup" = "nohup" ]
then (banner nohup
      echo "Start: \c"; date;
      set +o bgnice;
      /bin/time /usr/bin/nohup "$@" 2>&1
      echo "Finish: \c"; date; ) > $log &
     [ -z "$nohupout" ] && /bin/tail -f $log
elif [ "$noout" = "noout" ]
then (banner noout
      echo "Start: \c"; date;
      /bin/time "$@" 2>&1
      echo "Finish: \c"; date; ) > $log
else (banner normal
      echo "Start: \c"; date;
      /bin/time "$@" 2>&1
      echo "Finish: \c"; date; ) | tee $log
fi

exit 0

# Local Variables:
# mode: indented-text
# End:
