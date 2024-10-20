#! /bin/sh -e

prog="mvln"

if [ $# -ne 2 ]
then
    echo "usage: $prog file_dir target_dir" >&2
    exit 1
fi

src="$1"
dst="$2"

if [ ! -e "$src" ]
then
    echo "$prog: $src: does not exist" >&2
    exit 1
fi

if [ ! -e "$dst" ]
then
    echo "$prog: $dst: does not exist" >&2
    exit 1
fi

if [ ! -d "$dst" ]
then
    echo "$prog: $dst: not a directory" >&2
    exit 1
fi

dstsrc="$dst/$src"

if [ -e "$dstsrc" ]
then
    echo "$prog: $dstsrc: already exists" >&2
    exit 1
fi

echo "+ mv $src $dst && ln -s $dst/$src ." >&2

mv "$src" "$dst" && ln -s "$dst/$src" .

exit 0