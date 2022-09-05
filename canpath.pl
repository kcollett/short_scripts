#! /usr/local/bin/perl

# canpath -- given one or more paths, generate corresponding
#	     canonicalized absolute paths

# create canonicalized program name for messages
$prog = $0;
$prog =~ s,^.*/([^/]+)$,$1,;

# check for arguments
die "Usage: $prog path [path ...]\n" unless @ARGV;

($pwd = $ENV{'PWD'}) || chop ($pwd = `pwd`) || die "$prog: cannot determine current directory: $!\n";
@cwd = split (m;/;, $pwd);

foreach $arg (@ARGV)
{
    @path = split (m;/;, $arg);

    if ($path[0])		# if $path doesn't begin with a slash,
    {				# init canpath to the cwd
	@canpath = @cwd;
    }
    else			# else, init canpath with an empty element
    {
	@canpath = '';
    }

    foreach $component (@path)
    {
	next if $component eq '.' || !$component;
	pop (@canpath), next if $component eq "..";
	push (@canpath, $component);
    }

    print join ('/', @canpath) || '/', "\n";
}

# Local Variables:
# mode: perl
# End:
