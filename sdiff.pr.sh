#! /bin/sh

[ $# -ne 2 ] && { echo "usage: $0 oldfile newfile" >&2; exit 1; }
oldfile="$1"
newfile="$2"

/usr/bin/sdiff -l -w170 "$oldfile" "$newfile" |
/bin/pr -h "$newfile changes" -n1 -l64 |
/usr/bin/lp -ol -t"$newfile changes"
