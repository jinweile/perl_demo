#!/usr/bin/perl
use strict;
use Cache::Memcached;

my @servers=("localhost:11211");
my $pushinfo="hello world!";
foreach my $server(@servers){
	my $cache = Cache::Memcached->new(servers => [$server]);
	for(my $i=0;$i<100;$i++){
		my $key = "10000".("0" x (6- length($i))).$i."00000";
		$cache->set($key, $pushinfo, 3600 * 24 * 30);
		if($i % 10 ==0 ){
			print "already okay";
		}
	}
}