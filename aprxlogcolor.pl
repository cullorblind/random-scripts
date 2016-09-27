#!/usr/bin/perl
#
use Ham::APRS::FAP qw(parseaprs);

$black    = "\033[30m";
$red      = "\033[31m";
$green    = "\033[32m";
$yellow   = "\033[33m";
$blue     = "\033[34m";
$magenta  = "\033[35m";
$purple   = "\033[35m";
$cyan     = "\033[36m";
$white    = "\033[37m";
$darkgray = "\033[30m";

$col_norm =       "\033[00m";
$col_background = "\033[07m";
$col_brighten =   "\033[01m";
$col_underline =  "\033[04m";
$col_blink =      "\033[05m";

# Resets to normal colours and moves to the left one column ... 
$col_default = "$col_norm$white";
print "\n$col_norm$cyan";
print "aprxlogcolor.pl by$col_brighten$cyan Damon Massey$col_norm$cyan <$col_brighten$green";
print "ke5kul\@amarillowireless.net$col_norm$cyan";
print ">\n";

mainloop: while (<>)
{
	$thisline = $_;
	print;

	$timestamp = substr($_,0,23);
	s/........................//;

	@rec = split (/\s+/,$_,3);

	# DATE
	$output = "$col_brighten$cyan$timestamp";

	# SOURCE
	$output .=" $col_brighten$blue$rec[0]";

	# Tx/Rx
	$output .= "   ";
	if ($rec[1] eq "R") {

		$output .=" $col_norm$yellow$rec[1]";	# Rx

	} elsif ($rec[1] eq "T") {

		$output .=" $col_brighten$red$rec[1]";	# Tx

	} else {

		$output .=" $col_brighten$white$rec[1]";	# Other?

	}

	$aprspacket = $rec[2];
	chomp($aprspacket);
	my %packetdata;
	my $retval = parseaprs($aprspacket, \%packetdata);

	if ($retval == 1) {
		$output .= " ";
		#source
		$output .= "$col_brighten$purple$packetdata{srccallsign}$col_default>";

		#destination
		$output .= "$col_brighten$green$packetdata{dstcallsign}$col_default,";

		#digi
		@listref = @{ $packetdata{'digipeaters'} };
		foreach my $hashref ( @listref ) {
			#print "call=$hashref{'call'}";
			while (my ($key, $value) = each(%$hashref)) {
				if ("$key" eq "call") {
					$call = $value;
				}
				if ("$key" eq "wasdigied" && "$value" eq "1") {
					$wasdigied = "*";
				}
			}
			$output .= "$col_brighten$blue$call$wasdigied,";
			$wasdigied = "";
			#print "$call$wasdigied,";
		}
		$output =~ s/,$/:/;

		#body
		$output .= "$col_norm$cyan$packetdata{body}$col_default";

	} else {
		#invalid
		$output .=" $col_brighten$red$aprspacket";
	}


	print "$output$col_default\033[1G\n";

}

exit(0);
