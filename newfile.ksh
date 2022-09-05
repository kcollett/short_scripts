#! /bin/ksh

prog="${0##*/}"

case "$1" in
    -*)
	cat <<-EOF >&2
		usage: $prog [file ...]
		
		For one or more files, if file.new exists:
		     mv file file.old
		     mv file.new file

		Otherwise:

		     mv file file.old
		     cp file.old file
		     chmod +w $file

		The files can given on command line or via stdin.
		EOF
	exit 1
	;;
esac

integer status=0

if (($#))
then for arg in "$@"; do echo "$arg"; done
else while read arg;  do echo "$arg"; done
fi |
while read file
do
    if [ ! -f "$file.new" ]
    then
	[ ! -f "$file.old" ] \
	     && (set -x
		 mv "$file" "$file.old" \
		     && cp "$file.old" "$file" \
		     && chmod +w "$file") \
	     || echo "$file: $file.old exists" >&2
	((status = $status + $?))
    else
	 (set -x
	  mv "$file" "$file.old" && mv "$file.new" "$file")
	((status = $status + $?))
    fi
done

exit $status

# Local Variables:
# mode: ksh
# End:
