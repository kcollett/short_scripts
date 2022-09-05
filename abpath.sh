#!/bin/sh
#
#  abpath -- determine the absolute path of the given argument
#

# check syntax
[ $# -gt 1 ] && { echo "usage: $0 [<path>]" 1>&2; exit 1; }

# if null path, simply echo the current working directory and exit
[ $# -eq 0 ] && { echo `pwd`; exit 0; }

#
#  Set curpath to hold the components of the path.  If the path is
#  relative or no path is given, begin with components of the current
#  working directory.  If path is given, also tack on its components.
#
curpath=
OLDIFS="$IFS"
IFS="/"

# if relative path, first tack on elements of the current working
# directory
case $1 in
    /*)
	: do nothing
	;;
    *)	
	for comp in `pwd`
        do
            curpath="$curpath $comp"
	done
	;;
esac

for comp in $1
do
    curpath="$curpath $comp"
done

IFS="$OLDIFS"

#
#  Now, set $* to the components of the absolute path in reverse order.
#  ($* is used so that we can use shift.)
#
set -- ""
for comp in $curpath
do
    case $comp in
    .)
        : if ., then ignore
        ;;
    ..)
        : if .., and we are not at /, discard last element
        [ $# -ne 0 ] && shift
	;;
    *)
        : if not . or .., just tack onto $*
        set -- $comp $*
        ;;
    esac
done

#
#  Finally, construct the result path by concatenation the compontents
#  of $* in reverse order, separated by /'s
#
respath=
for comp
do
    respath="/$comp$respath"
done

[ "$respath" = "" ] && respath="/"

echo "$respath"

exit 0
