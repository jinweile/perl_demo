#!/usr/bin/perl -w

use strict;
 
my $request = "manual=true&model=iPhone%20Simulator&ver=2.7.2&signKey=43087115F6EDFC293E14C9C036C3F885";
my @querys = split(/&/, $request);
my %query_hash;
foreach my $query (@querys) {
	my @key_value = split(/=/, $query);
	$query_hash{$key_value[0]} = $key_value[1];
}

my @sort_values = sort(keys %query_hash);
foreach my $key (@sort_values) {
	my $value = $query_hash{$key};
	print $key.":".$value."\n";
}