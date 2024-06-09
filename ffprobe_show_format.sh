#! /bin/sh -x

ffprobe -show_format -print_format json "$@" 2>/dev/null
