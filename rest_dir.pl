#! /usr/local/bin/perl

# save canonical version program name
($prog = $0) =~ s,^.*[/\\]([^/\\]+)$,$1,;

require ('kcollett/cmd.pl');

sub backUsage
{
    die "usage: $prog [-o] <backup name> <dir> [<dir> ...]\n";
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

# set overwrite boolean based on presence of -o argument
$bOverwrite = $ARGV[0] eq "-o" && shift;

@ARGV == 0 && ($bBackup ? &backUsage : &restUsage);

$backupName = shift;
$backupFile = "$backupName.tar.gz";

if ($bBackup)
{
    &backUsage if (@ARGV == 0);

    -f $backupFile && ! $bOverwrite &&
	die "$prog: backup file exists: $backupFile\n";

    $cmd = "tar cvf -";
    foreach $dir (@ARGV)
    {
	$cmd .= " \"$dir\"";
    }
    $cmd .= " | gzip >\"$backupFile\"";
    &docmd ($cmd);
    $? && die "$prog: command failure: $cmd\n";
}
else
{
    &restUsage if (@ARGV != 0);

    -f "$backupFile" || die "$prog: $backupFile does not exist\n";

    $cmd = "gunzip -c \"$backupFile\" | tar xvf -";
    &docmd ($cmd);
    $? && die "$prog: command failure: $cmd\n";
}

exit 0
