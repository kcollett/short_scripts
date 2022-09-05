#! /bin/perl


$0 =~ s,.*[/\\]([^/\\]+)$,$1,;	# canonicalize program name 

unless (@ARGV)
{
    print STDERR "usage: $0 <decimal value> [<decimal value> ...]\n";
    exit (1);
}

foreach $value (@ARGV)
{
    printf "0x%x\n", $value;
}
