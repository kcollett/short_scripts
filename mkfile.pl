#!/usr/local/bin/perl

# create canonicalized program name for messages
($prog = $0) =~ s,^.*/([^/]+)$,$1,;

# usage function
sub usage
{
    die "usage: $prog [-fill] size[K|b|M] filename ...\n";
}

$fill = 0;
if ($ARGV[0] == "-fill")
{
    $fill = 1;
    shift (@ARGV);
}

# check for arguments
&usage unless $#ARGV ge 1;

# extract and check size argument
$size = shift (@ARGV);
&usage unless $size =~ /^[0-9]+(b|K|M)?$/;

# check for size suffixes and adjust $size accordingly
if ($size =~ /.*b/)
{
    $size =~ s/b$//;
    $size *= 512;
}
elsif ($size =~ /.*K/)
{
    $size =~ s/K$//;
    $size *= 1024;
}
elsif ($size =~ /.*M/)
{
    $size =~ s/M$//;
    $size *= 1024 * 1024;
}

while (@ARGV)
{
    $file = shift (@ARGV);

    # make sure file doesn't exist
    die "$file: already exists" if -e $file;

    open (FILE, ">$file") || die "$prog: open failure: $!";

    if ($size)
    {
	if ($fill)
	{
	    # this first loop is a speed optimization
	    $nEights = $size / 8;
	    $cnt = 1;
	    while ($cnt <= $nEights)
	    {
		printf FILE "%s", "\377\377\377\377\377\377\377\377";
		$cnt++;
	    }

	    $cnt = ($nEights * 8) + 1;
	    while ($cnt <= $size)
	    {
		printf FILE "%s", "\377";
		$cnt++;
	    }
	}
	else
	{
	    seek (FILE, $size - 1, 0) || die "$prog: seek failure: $!";
	    printf FILE "%s", "The End" || die "$prog: print failure: $!";
	}
    }

    close (FILE) || die "$prog: close failure: $!";

    chmod (0600, $file) || die "$prog: chmod failure: $!";
}

exit (0);

# Local Variables:
# mode: perl
# End:
