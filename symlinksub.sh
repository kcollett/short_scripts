#! /bin/sh

[ $# -lt 2 ] && { echo "usage: $0 old new [symlink ...]" >&2; exit 1; }

old="$1"; new="$2"; shift 2

if [ $# -eq 0 ]
then while read arg; do echo "$arg"; done
else for arg in "$@"; do echo "$arg"; done
fi |
while read link
do
    [ ! -h $link ] && { echo "$link: not a symlink" >&2; continue; }

    newsymlink=`ls -l $link | sed -e 's,.*-> ,,' -e "s,$old,$new,"`
    echo $link: $newsymlink
    rm $link
    ln -s $newsymlink $link
done

exit 0
