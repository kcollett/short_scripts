#! /bin/sh

set -e

# process arguments
[ $# -lt 2 ] && { echo "usage: $0 string1 string2 [file ...]" >&2; exit 1; }
string1=$1; string2=$2; shift 2

# temporary directory
tmpdir=/var/tmp/sip$$

# cleanup function
cleanup()
{
    rmdir $tmpdir
    [ $# -ne 0 ] && exit $* || exit 0
}

trap "cleanup 1" 1 2 3 9 15

# create temporary directory
mkdir $tmpdir

if [ $# -eq 0 ]
then while read arg;  do echo "$arg"; done
else for arg in "$@"; do echo "$arg"; done
fi |
while read file
do
    [ ! -f $file ] && { echo "$file: no such file" >&2; continue; }
    [ ! -w $file ] && { echo "$file: not writable" >&2; continue; }
    tmpfile=$tmpdir/`basename $file`

    echo "$file:"

    sed -e "s,$string1,$string2,g" $file >$tmpfile

    set +e
    cmp -s $file $tmpfile
    status=$?
    set -e

    case $status in
	0) echo "	no $string1 matches found"
	   rm $tmpfile
	   continue;;
        1) mv $tmpfile $file;;
	2) echo "$file: substitution results unknown, see $tmpfile" >&2
	   continue;;
	*) echo "$file: unexpected status from cmp" >&2
	   continue;;
    esac
done
    
cleanup
