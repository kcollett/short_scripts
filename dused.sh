#! /bin/sh

#
# dused -- compute total disk space used via du
#

dused=0

if [ $# -ne 0 ]
then for file in "$@"; do echo "$file"; done
else while read file; do echo "$file"; done
fi |
xargs /bin/du -s |
/usr/bin/awk '{ dused = dused + $1 }
              END { print dused }'

exit 0
