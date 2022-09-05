#! /bin/sh

du -sm * | sort -rn +0 -1

exit $?
