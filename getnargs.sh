#! /bin/sh

if [ $# -eq 0 ]
then
    while read arg
    do
        echo $arg
    done
else
    for arg in "$@"
    do
        echo $arg
    done
fi

exit 0
