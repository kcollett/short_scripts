#! /usr/bin/perl

# canonicalize program name
$0 =~ s,^.*/([^/]+)$,$1,;

# this doesn't seem to quite work :-(
STDOUT->autoflush(1);

sub files_in_dir
{
    local (@files) = ();
    local ($dir) = @_;

    if (@_ != 1)
    {
	print STDERR "usage: files_in_dir (<dir>)\n";
	return (@files);
    }

    if ($dir eq "")
    {
	$dir = ".";
    }

    if (defined ($cached_files{$dir}))
    {
        @files = $cached_files{$dir};
    }
    elsif (! opendir (DIR, $dir))
    {
        print STDERR "files_in_dir: opendir of $dir failed: $!\n";
    }
    else
    {
	@files = readdir (DIR);

	$cached_files{$dir} = @files;

	closedir (DIR); # || warn "closedir() of $dir failed: $!";
    }

    return (@files);
}

@files = ();
if (@ARGV)
{
    while (@ARGV)
    {
	$arg = shift;
	
	if (-d $arg)
	{
	    $arg =~ s,/*$,,;	# remove trailing slashes
	    push (@files, grep ($_ = "$arg/$_", &files_in_dir ($arg)));
	}
	elsif (-e $arg)
	{
	    if ($arg =~ m,^(.*)/([^/]+)$,)
	    {
		$dir = $1;
		if ($dir eq "")
		{
		    $dir = "/";
		}
		$file = $2;
	    }
	    else
	    {
		$dir = ".";
		$file = $arg;
	    }

	    @fid = &files_in_dir ($dir);
	    push (@files, grep ($_ = "$dir/$_",
				grep (/^$file.*$/, @fid)));
	}
	else
	{
	    print STDERR "$arg: no such file or directory\n";
	}
    }
}
else
{
    @files = &files_in_dir (".");
}

# bail unless we have any files to purge
exit (0) unless @files;


$cDesiredMaxLineChars = 80;
$sTag = "Purging...";

$cTagChars = length ($sTag);

print $sTag;

$cFilesOnLine = 0;
$cLineChars = $cTagChars;

# for every file ending with '~'...
foreach $file_to_remove (grep (/~$/, @files))
{
    if (unlink ($file_to_remove))
    {
	$sFileOut = " $file_to_remove";
	$cFileOutChars = length ($sFileOut);

	# should we start a new line of output?
	if ($cLineChars + $cFileOutChars > $cDesiredMaxLineChars
	    && $cFilesOnLine) # output at least one file per line
	{
	    # start new line of output
	    print "\n" . (' ' x $cTagChars);
	    $cLineChars = $cTagChars;
	    $cFilesOnLine = 0;
	}

	print $sFileOut;

	$cLineChars += $cFileOutChars;
	$cFilesOnLine++;
    }
    else
    {
	print STDERR "$0: unlink of $file_to_remove failed: $!\n";
    }
}
print "\n";

exit (0);
