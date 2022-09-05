#! /bin/sh

if [ $# -eq 0 ]
then while read arg;  do echo "$arg"; done
else for arg in "$@"; do echo "$arg"; done
fi |
while read dir
do
    (set -x;
    tar cf - "$dir" |
    gzip >"$dir.tar.gz" && rm -rf "$dir")
done

exit 0
