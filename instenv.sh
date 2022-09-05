#! /bin/sh
#
# instenv -- copy environment over to machines without rdist(1).
#
set -e

use_ftp=0
full=0
dir=""
while [ $# -gt 2 ]
do case $1 in
       -ftp)	use_ftp=1; shift;;
       -full)	full=1; shift;;
       -dir)	dir=$2; shift 2;;
   esac
done

[ $# -ne 2 ] && { echo "usage: $0 [-ftp] [-full] [-dir <target directory>] <target machine> <file list>" >&2;
		  exit 1; }
target=$1; flist=$2

tmpname=ie$$
tmp=/usr/tmp/$tmpname

cpio_compat_opts="-c"

cd $HOME
cat $flist | xargs -i find {} -print | cpio $cpio_compat_opts -o >$tmp

if [ "$use_ftp" -eq 1 ]
then 
    ftp -v $target <<EOF
bin
lcd /usr/tmp
put $tmpname
quit
EOF
    echo "You must manually extract from $tmpname on $target"
else
    rcp $tmp $target:/usr/tmp
    [ $full -eq 0 ] && cpioopts="$cpio_compat_opts -imd" \
		    || cpioopts="$cpio_compat_opts -imdu"
    [ ! -z "$dir" ] && cdcmd="cd $dir; " || cdcmd=""
    rsh $target "${cdcmd}cpio $cpioopts <$tmp"
    rsh $target "/bin/rm $tmp"
fi

/bin/rm -f $tmp

exit 0
