#! /usr/local/bin/perl

unless (@ARGV)
{
    print STDERR "usage: $0 <file> [<file> ...]\n";
    exit (1);
}

$nFailures = 0;
foreach $file (@ARGV)
{
    $origfile = $file . ".orig";

    unless (-f $file)
    {
	print STDERR "$file: no such file--skipping...\n";
	$nFailures++;
	next;
    }

    if (-f $origfile)
    {
	print STDERR "$file: .orig file exists--skipping...\n";
	$nFailures++;
	next;
    }

    rename ($file, $origfile) || die "$file: rename to $origfile failed";

    open (INFILE,  "<$origfile") || die "$origfile: open failed";
    open (OUTFILE, ">$file")     || die "$file: open failed";

    binmode INFILE;
    binmode OUTFILE;

    while (<INFILE>)
    {
#	print "read:", $_, "\n";
	chop;
	s/\r$//;
#	print "subbed:", $_, "\n";
	print OUTFILE $_, "\n";
    }

    close (INFILE)  || die "$origfile: close failed";
    close (OUTFILE) || die "$file: close failed";
}

exit ($nFailures);
