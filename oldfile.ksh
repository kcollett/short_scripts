#! /bin/ksh

prog="${0##*/}"
type="${prog%file}"

case "$1" in
    -*)
	cat <<-EOF >&2
		usage: $prog [file ...]

		For one or more files:
		     mv file file.new
		     mv file.$type file

		The files can given on command line or via stdin.
		EOF
	exit 1
	;;
esac

integer status=0

if (($# == 0))
then while read arg;  do echo "$arg"; done
else for arg in "$@"; do echo "$arg"; done
fi |
while read file
do
    (set -x
     mv "$file" "$file.new" && mv "$file.$type" "$file")
     ((status = $status + $?))
done

exit $status

# Local Variables:
# mode: ksh
# End:
