#!/usr/local/bin/perl
#  -*- mode: perl; -*-

# canonicalize program name
$0 =~ s,^.*/([^/]+)$,$1,;

# number of days in each month of year
@days_in_month = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

# usage subroutine
sub usage
{
    print STDERR "	SYNOPSIS\n
	    $0 -- t-time script

	USAGE\n
	    $0 [-count] yyyy:mm:dd:hh:mm:ss\n
		where yyyy:mm:dd:hh:mm:ss specifies the target date/time.
		The time must be specified must be UTC/GMT.

	OPTIONS\n
	    -count\n
		run indefinitely, redisplaying the t-time every second

	AUTHOR\n
	    Karen Collett\n";
    exit (1);
}

# check for no arguments
&usage if -1 == $#ARGV;

# process arguments
while (@ARGV)
{
    $_ = shift (@ARGV);

    if    (/-count/)	{ $count = 1; }
    elsif (/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}/)
			{ ($bYear, $bMonth,  $bDay,
			   $bHour, $bMinute, $bSecond) = split (/:/, $_); }
    else		{ &usage; }
}

# determines whether a given year is a leap year (probably not bulletproof)
sub isleapyear
{
    local ($year) = @_;

    return (! ($year & 3));	# somebody fix this before 2100
}

# decomposes seconds into days, hours, minutes, and seconds
sub expand_seconds
{
    local ($seconds) = @_;
    local ($tDays, $tHours, $tMinutes);

    $tDays = int ($seconds / (24*60*60));
    $seconds -= $tDays * 24*60*60;

    $tHours = int ($seconds / (60*60));
    $seconds -= $tHours * 60*60;

    $tMinutes = int ($seconds / 60);
    $seconds -= $tMinutes * 60;

    return ($tDays, $tHours, $tMinutes, $seconds);
}

# given the delta time in seconds, prints the T[+-] version of the delta
sub print_ttime
{
    local ($tminus) = @_;
    
    if ($tminus < 0)
    {
	$tminus = -$tminus;
	printf "T-";
    }
    else
    {
	printf "T+";
    }

    $ttime = sprintf ("%d %02d:%02d:%02d", &expand_seconds ($tminus));
#    &printflush (STDOUT, $ttime);
    STDOUT->printflush ($ttime);
}

#
# check the input base time
#
if ($bYear < 1970)
{
    print STDERR
	  "Sorry, cannot do dates earlier than January 1, 1970 (UNIX epoch).\n";
    exit (1);
}

if ($bMonth < 1 || $bMonth > 12)
{
    print STDERR
    	  "$bMonth: bad value for month\n";
    exit (1);
}

if (($bDay < 1 || $bDay > $days_in_month[$bMonth - 1])
    && ! (&isleapyear ($bYear)
    	  && ($bMonth == 2)
	  && ($bDay == 29)))
{
    print STDERR "$bDay: bad value for day\n";
    exit (1);
}

if ($bHour > 23)
{
    print STDERR "$bHour: bad value for hour\n";
    exit (1);
}

if ($bMinute > 59)
{
    print STDERR "$bMinute: bad value for minute\n";
    exit (1);
}

if ($bSecond > 59)
{
    print STDERR "$bSecond: bad value for second\n";
    exit (1);
}

#
# determine UNIX time equivalent to the input base time
#

# determine the number of intervening leap years
$nLeapYears = 0;
for ($year = 1970; $year < $bYear; $year++)
{
   $nLeapYears++ if (&isleapyear ($year));
}

# determine how many days in the year the base time is
$nDays = 0;
for ($month = 0; $month < ($bMonth - 1); $month++)
{
    $nDays += $days_in_month[$month];
}
$nDays++ if (&isleapyear ($bYear) && $bMonth > 2);
$nDays += ($bDay - 1);

# compute UNIX time equivalent
$bTime = ($bSecond
	  + 60 * ($bMinute
		  + 60 * ($bHour
			  + 24 * ($nDays
				  + $nLeapYears
				  + 365 * ($bYear - 1970)))));

#
# print T[+-] time, either repeatedly or once, depending upon whether -count
# was specified
#
if ($count)
{
    while (1)
    {
	system ("clear");
	&print_ttime (time - $bTime);
	sleep (1);
    }
}
else
{
    &print_ttime (time - $bTime);
}

exit (0);
