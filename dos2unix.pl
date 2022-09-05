#! /usr/bin/perl -w

binmode STDOUT;

while (<>)
{
    chop;
    s/\r$//;
    print $_,"\n";
}
