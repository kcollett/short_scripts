#!/usr/bin/perl
# ipq -    Answer one of the two common IP queries
#
# Tim Cook, December 1992

$prog = substr ($0, rindex ($0, '/') + 1);

die "usage: $prog { hostname | IP-address }\n" if ($#ARGV != 0);

if ($ARGV[0] =~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
   &address_to_name ($ARGV[0]); }
else {
   &name_to_address ($ARGV[0]); }

exit (0);

sub name_to_address {
   local ($name) = shift (@_);
   local (@octets);
   local ($nam, $aliases, $addrtype, $length, $address) =
      gethostbyname ($name);

   die "$prog: no address found for $name\n" if (! length ($address));

   @octets = unpack ("CCCC", $address);

   print (join ('.', @octets[0..3]), "\n");
   }

sub address_to_name {
   local ($address) = shift (@_);
   local (@octets);
   local ($name, $aliases, $type, $len, $addr);
   local ($ip_number);

   @octets = split ('\.', $address) ;

   die "$prog: IP-address must have four octets\n" if ($#octets != 3);

   $ip_number = pack ("CCCC", @octets[0..3]);

   ($name, $aliases, $type, $len, $addr) = gethostbyaddr ($ip_number, 2) ;

   die "$prog: no host-name found for $address\n" unless ($name) ;

   print ($name, "\n");
   }
