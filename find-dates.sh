#! /bin/sh -x

find "$@" -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n'
