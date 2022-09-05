#! /bin/sh

[ $# -lt 2 ] && { echo "usage: $0 file [file ...] target" >&2; exit 1; }

srcs=""
while [ $# -ne 1 ]
do
   srcs="$srcs $1"
   shift
done
target="$@"

find $srcs -print | cpio -pmdv "$target"

exit $?
