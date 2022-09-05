#! /bin/sh
#
# llp -- print one or more files in two column/landscape style
#
#	syntax: llp <lp options> [file ...]
#

set -e

true=y
false=

lpopts=""
title=""
while getopts cmsd:n:o:t: lpopt
do
    [ "X$lpopt" = "X?" ] && exit 1
    case "$lpopt" in
	t*)
	    title="$OPTARG"
	    ;;
    esac
    [ ! -z "$lpopts" ] && lpopts="$lpopts "
    lpopts="${lpopts}-$lpopt"
    [ "$OPTARG" ] && lpopts="$lpopts$OPTARG"
done
#ignore possible expr exit value of 1
set +e
shift `expr $OPTIND - 1`
set -e

files="$@"
echo "$lpopts" >&2
echo "$files"  >&2
echo "$title"  >&2

set -- $files
if [ -z "$files" ]
then
    [ "$title" ] && /bin/pr -l64 -h "$title" || /bin/pr -l64 -h stdin
else
    for file in "$@"
    do
	/bin/pr -l64 -h "$file" "$file"
    done
fi | tee pr1 |
/bin/pr -t -2 -w175 -l64
exit 1
# (echo 'E(10U(s0p10.00h12.00v0s0b3T&l1o7.99c51p2A&k3G'
#  cat
#  echo 'E') |
if [ -z "$lpopts" ]
then
    lp -y date -y page_nums -y landscape
else
    lp "$lpopts" -y date -y page_nums -y landscape -y font=Courier-Bold8
fi

exit 0
