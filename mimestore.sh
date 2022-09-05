#! /bin/sh -x

[ $# -ne 2 ] && { echo "usage: $0 <parameters> <content-subtype>" >&2;
		  exit 1; }

parms="$1"
subtype="$2"

name=

oldIFS="$IFS"
IFS="="
parm_name=

for word in $parms
do
    #echo "|$word|"
    if [ "$parm_name" ]
    then
	parm_value="$word"
	echo "${parm_name}=${parm_value}"
	parm_name=
    else
	parm_name="$word"
    fi
done |
while read parm_name2 parm_value2
do
    echo "$parm_name2"
    echo "$parm_value2"
    case "$parm_name2" in
	name)
	    name="$parm_value2"
	    ;;
	*)
	    echo "$0: unknown parameter: $parm_name2" >&2
	    ;;
    esac
done
IFS=$oldIFS

case $subtype in
    octet-stream)
	if [ "$name" ]
	then
	    unquoted_name=`eval echo $name`
	    cat > $HOME/tmp/$unquoted_name
	else
	    cat >/dev/null
	fi
	;;
    *)
	cat >/dev/null
	;;
esac

echo "$1" "$2" >~/tmp/mime.log
echo "$name"   >>~/tmp/mime.log

exit 0
