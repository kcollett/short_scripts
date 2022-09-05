#! /bin/sh

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

[ $# -ne 1 ] && { echo "usage: $0 inet-address" >&2; exit 1; }

(IFS="."; export IFS; set -- $1; echo $1 $2 $3 $4) |
dec2hex |
{
    while read hexoct
    do
        case $hexoct in
	    ?)	echo "0$hexoct\c";;
	    ??)	echo "$hexoct\c";;
	    *)	echo "error!" >&2;;
        esac
    done
    echo ''
} |
tr [a-z][A-Z]
echo $IFS

exit 0
