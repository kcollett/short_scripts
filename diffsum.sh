#! /bin/sh

# diffsum -- compare the output of two mksum output files.

set -e

[ $# -ne 2 ] && { echo "usage: $0 file file" >&2; exit 1; }
file1="$1"; file2="$2"

/bin/diff "$file1" "$file2" |
/usr/bin/egrep '^[<>]' |
/usr/bin/cut -d' ' -f4 |
/usr/bin/uniq |
while read file
do
    echo "$file: \c"
    if /bin/grep "${file}$" "$file1" >/dev/null
    then
        if /bin/grep "${file}$" "$file2" >/dev/null
	then
	    echo "difference detected"
	else
            echo "not in $file2"
        fi
    else
        if /bin/grep "${file}$" "$file2" >/dev/null
	then
            echo "not in $file1"
	else
	    echo "not in either $file1 or ${file2}?!"
        fi
    fi
done


exit 0
