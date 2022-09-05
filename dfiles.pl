#! /usr/bin/perl

while (@ARGV)
{
    $dir = shift (@ARGV);

    opendir (DIR, $dir) || die "opendir: $!\n";

    foreach $ent (readdir (DIR))
    {
        $file = "$dir/" . $ent;
	print $file, "\n" if -d $file;
    }

    closedir (DIR);
}

# Local Variables:
# mode: perl
# End:
