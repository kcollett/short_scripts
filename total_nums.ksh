#! /bin/ksh

$KSH_DEBUG

integer total=0

awk '{ print $1; }' |
while read num
do
    ((total += $num))
done

echo $total

exit 0
