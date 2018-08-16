#!/usr/bin/perl -w

my $operation;
my $totalrps = 0;
my $lat50_max = 0;
my $lat95_max = 0;
my $lat99_max = 0;
my $lat99_90_max = 0;
my $lat99_99_max = 0;

while (<>) {
	chomp;
	my @lineFields = split /\,/,;

	my @oper = split /"/,$lineFields[0];
	$operation = $oper[1];
	my @requestspersecond = split /"/,$lineFields[1];

	$totalrps += $requestspersecond[1];

	my @lat50 = split /"/,$lineFields[2];
	if ($lat50_max < $lat50[1]) {
		$lat50_max = $lat50[1];
	}

	my @lat95 = split /"/,$lineFields[3];
	if ($lat95_max < $lat95[1]) {
		$lat95_max = $lat95[1];
	}

	my @lat99 = split /"/,$lineFields[4];
	if ($lat99_max < $lat99[1]) {
		$lat99_max = $lat99[1];
	}

	my @lat99_9 = split /"/,$lineFields[5];
	if ($lat99_90_max < $lat99_9[1]) {
		$lat99_90_max = $lat99_9[1];
	}

	my @lat99_99 = split /"/,$lineFields[6];
	if ($lat99_99_max < $lat99_99[1]) {
		$lat99_99_max = $lat99_99[1];
	}
}
my $rps = sprintf( "%.2fM", $totalrps/1000000 );
print ("$operation,$rps,$lat50_max,$lat95_max,$lat99_max,$lat99_90_max,$lat99_99_max\n");
