#! /bin/sh -e

if [ $# -eq 0 ]
then while read arg;  do echo "$arg"; done
else for arg in "$@"; do echo "$arg"; done
fi |
while read dir
do
    (set -x;
     tar --totals --create --file - "$dir" | gzip --verbose >"$dir.tgz")
done

exit 0
