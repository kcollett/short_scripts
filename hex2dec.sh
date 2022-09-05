dec2hex()
{
    tmp=/var/tmp/d2h$$

    echo 'obase=16' >$tmp

    if [ $# -eq 0 ]
    then while read arg; do echo $arg; done
    else for farg in "$@"; do echo $farg; done
    fi |
    while read dec
    do
	set -- $dec
	for darg in "$@"
	do
	    echo $darg >>$tmp
	done
    done

    echo "quit" >>$tmp

    bc <$tmp

    rm -f $tmp
    return 0
}
