#! /bin/ksh
# ls given arguments, screening for directories

opts=""
while getopts RadLCxmlnogrtucpFbqisf1 opt
do
    opts="${opts} -$opt"
done
shift `expr $OPTIND - 1`

/bin/ls -d $opts `dfiles $*`

exit $?
