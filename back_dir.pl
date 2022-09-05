#! /usr/bin/perl

# save canonical version program name
($prog = $0) =~ s,^.*[/\\]([^/\\]+)$,$1,;

require 'flush.pl';		# for printflush()

sub docmd
{
    local ($ignore_error) = 0;

    if ($_[0] eq '-i')
    {
	$ignore_error = shift;
    }

    unless (@_ >= 1)
    {
	print STDERR "usage: docmd -i <command> [<arg> ...]";
	return (1);
    }

    &printflush (STDERR, "+ " . join (' ', @_) . "\n");
    system (@_);

    $ignore_error || $? && die "command failed: $!";
}

sub backUsage
{
    die "usage: $prog [--exclude <exclude-pattern>] [-o] <backup name> <dir> [<dir> ...]\n";
}

sub restUsage
{
    die "usage: $prog <backup name>\n";
}

# determine our mode
if ($prog =~ /^back/)
{
    $bBackup = 1;
}
elsif ($prog =~ /^rest/)
{
    $bBackup = 0;
}
else
{
    die "$prog: bad program name";
}


while ($ARGV[0] eq '--exclude')
{
    shift;
    push (@excludePatterns, shift);
}

# set overwrite boolean based on presence of -o argument
$bOverwrite = $ARGV[0] eq "-o" && shift;

@ARGV == 0 && ($bBackup ? &backUsage : &restUsage);

$backupName = shift;
$backupFile = "$backupName.tgz";

if ($bBackup)
{
    &backUsage if (@ARGV == 0);

    -f $backupFile && ! $bOverwrite &&
	die "$prog: backup file exists: $backupFile\n";

    $cmd  = 'tar --totals --gzip --create';
    foreach $excludePattern (@excludePatterns)
    {
        $cmd .= " --exclude='$excludePattern'";
    }
    $cmd .= " --file \"$backupFile\"";
    foreach $dir (@ARGV)
    {
	$cmd .= " \"$dir\"";
    }
    &docmd ($cmd);
    $? && die "$prog: command failure: $cmd\n";
}
else
{
    &restUsage if (@ARGV != 0);

    -f "$backupFile" || die "$prog: $backupFile does not exist\n";

    $cmd = "gunzip --stdout \"$backupFile\" | tar --extract --verbose --file -";
    &docmd ($cmd);
    $? && die "$prog: command failure: $cmd\n";
}

exit 0
