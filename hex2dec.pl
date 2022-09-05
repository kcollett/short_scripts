#! /opt/local/bin/perl


$0 =~ s,.*[/\\]([^/\\]+)$,$1,;	# canonicalize program name 

unless (@ARGV)
{
    print STDERR "usage: $0 <hex value> [<hex value> ...]\n";
    exit (1);
}

foreach $value (@ARGV)
{
    $decValue = hex ($value);
    print $decValue, "\n";
}
