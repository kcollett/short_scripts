#! /usr/local/bin/perl

# canpath -- given one or more paths, generate corresponding
#	     canonicalized absolute paths

# create canonicalized program name for messages
$prog = $0;
$prog =~ s,^.*/([^/]+)$,$1,;

# check for arguments
die "Usage: $prog path [path ...]\n" unless @ARGV;

chop ($pwd = `pwd`) || die "$prog: cannot determine current directory: $!\n";
@cwd = split (m;/;, $pwd);

foreach $arg (@ARGV)
{
    @path = split (m;/;, $arg);

    @canpath = @cwd unless !$path[0];

    foreach $component (@path)
    {
	if ($component eq "..")	# decrement array count
	{
	    $#canpath--;
	}
	elsif ($component && $component ne ".")
	{
	    @canpath[$#canpath + 1] = $component;
	}
    }

    if ($#canpath)
    {
	print join ('/',@canpath), "\n";
    }
    else
    {
	print "/\n";
    }
}

# Local Variables:
# mode: perl
# End:
