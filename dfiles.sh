#! /bin/sh
#
# dfiles -- if no argument, then echo all subdirectories of .;
# otherwise, echo all subdirectories of each given directory.
#

if [ $# -ne 0 ]
then
    for dir in $*
    do
	for file in $dir/*
	do
            [ -d "$file" ] && echo $file
        done
    done
else
    for file in *
    do
        [ -d "$file" ] && echo $file
    done
fi

exit 0
