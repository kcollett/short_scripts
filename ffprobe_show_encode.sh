#! /bin/sh -x

ffprobe_show_format "$@" | grep "encod*"
