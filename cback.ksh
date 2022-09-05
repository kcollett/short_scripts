#! /bin/ksh

set -e				# exit on error

prog=${0##*/}			# save program name
true=true
false=
verbose=$true			# verbose mode by default
execute=$true			# execute mode by default

usage()
{
    echo "usage: $prog [-q] [-n] <archive name> <find path-list> [<find predicates>]" >&2
    exit 1
}

while [ $# -ne 0 ]; do
    case $1 in
        -q) verbose=$false; shift;;
	-n) execute=$false; shift;;
	-*) usage;;
         *) break;;	# stop option processing as soon as we see a non-option
    esac
done

[ $# -lt 2 ] && usage

archive="$1.cpio.gz"; shift

cleanup()
{
    echo "$prog: aborted"
    /bin/rm -f $archive
    exit 1
}
trap cleanup 1 2 15

# find 
find_cmd="find $@ -print"

# cpio
cpio_opts="-o"
[ "$verbose" ] && cpio_opts="$cpio_opts -v"
cpio_cmd="cpio $cpio_opts"

# compress
gzip_opts=""
[ "$verbose" ] && gzip_opts="$gzip_opts --verbose"
compress_cmd="gzip $gzip_opts"

cmd="$find_cmd | $cpio_cmd | $compress_cmd"
echo "$cmd >$archive" 
[ "$execute" ] && eval "$cmd" >$archive && echo archive is $archive

exit 0
