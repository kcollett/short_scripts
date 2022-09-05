#!/usr/bin/perl -w

# canonicalize program name
$0 =~ s,^.*[/\\]([^/\\]+)$,$1,;

if (@ARGV != 1)
{
    print STDERR "usage: $0 folder\n" >&2;
    exit (1);
}

$folder = shift;
if (! -d $folder)
{
    print STDERR "$folder: no such directory\n";
    exit (1);
}
