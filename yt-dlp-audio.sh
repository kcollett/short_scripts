#! /bin/sh

[ $# -ne 1 ] && { echo "usage: $0 <YT URL>" >&2; exit 1; }

set -xe
yt-dlp --extract-audio "$1"