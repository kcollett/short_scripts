#! /bin/sh

[ $# -lt 1 -o $# -gt 2 ] && \
	{ echo "usage: $0 <backing-dir> [<clone-dir>]" >&2; exit 1; }

bdir=$1
[ $# -eq 2 ] && cdir=$2 || cdir=`pwd`

dirlist=/var/tmp/clndir$$

cd $bdir
find . -type d -print >$dirlist
cat $dirlist | cpio -pdv $cdir
stat=$?

[ $stat -eq 0 ] && rm $dirlist

exit $stat
