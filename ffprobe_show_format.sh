#! /bin/sh -x

ffprobe -show_format "$@" 2>/dev/null
