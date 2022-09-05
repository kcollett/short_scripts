#! /bin/sh

#
#  purge -- get rid of emacs versions
#

#
#  For each file in $args, check to see if any versions exists and if
#  so, remove them.
#
echo -e "Purging...\c"
if [ $# -eq 0 ]; then echo ""
else for arg in "$@"; do echo "$arg"; done
fi |
while read arg
do
   if [ -z "$arg" ]
   then
        for file in * .*;           do echo "$file"; done
   elif [ -d "$arg" ]
   then 
        for file in $arg/* $arg/.*; do echo "$file"; done
   else
        for file in ${arg}*;        do echo "$file"; done
   fi
done |
sed -e '/^\.$/d' -e '/\/\.$/d' -e '/^\.\.$/d' -e '/\/\.\.$/d' |
while read file
do
    case "$file" in
        *~|*.~*~)
	    echo $file;;
    esac
done |
while read fileversion
do
     echo /bin/rm "$fileversion"
     'rm' "$fileversion" 2>/dev/null && echo -e " $fileversion\c"
done
echo -e "\ndone."

exit 0
