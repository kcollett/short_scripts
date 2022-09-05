#! /bin/sh

# mksum -- make a sorted, recursive checksum of the files in the given
#          (on the command line or via stdin) files and directories.
#          You can compare the results of two mksum's using diffsum.

set -e

if [ $# -eq 0 ]
then
    while read file; do echo "$file"; done
else
    for file in "$@"; do echo "$file"; done
fi |
xargs -I DIR find DIR -type f -print |
xargs sum |
sort +2 -3

exit 0
