#! /bin/sh

sdir=$1
mach=$2
cdopt=""
tuser=""

case $# in
    2) ;;
    3) tuser=" -l $3"
       ;;
    4) tuser=" -l $3"
       cdopt="cd $4; "
       ;;
    *) echo "usage: $0 sdir mach [tuser [tpdir]]" >&2
       exit 1
       ;;
esac

echo "tar cvf - $sdir | rsh $mach$tuser \"${cdopt}tar xvpf -\""
tar cvf - $sdir | rsh $mach$tuser "${cdopt}tar xvpf -"

exit $?
