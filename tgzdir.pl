#!/usr/bin/perl -w

# canonicalize program name
$0 =~ s,^.*[/\\]([^/\\]+)$,$1,;

if (@ARGV != 1)
{
    print STDERR "usage: $0 <directory>\n";
    exit (1);
}

$dir = shift;
if (! -e $dir)
{
    print STDERR "$dir: no such file or directory\n";
    exit (1);
}
if (! -d $dir)
{
    print STDERR "$dir: file is not a directory\n";
    exit (1);
}

$tdir = $dir . ".tgz";

if (-e $tdir)
{
    print STDERR "$tdir: file already exists\n";
    exit (1);
}

$cmd = "tar cvf - $dir | gzip -c >$tdir";
print "+ $cmd\n";
system ($cmd);

exit ($?);
