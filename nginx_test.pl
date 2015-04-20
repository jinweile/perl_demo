#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::Sybase;
use Cache::Memcached;
use Log::Log4perl;

#init logger
Log::Log4perl->init("./log4perl.conf");

#declare memcached server list
my @memcached_servers = ("localhost:11211");

#declare sqlserver
my $database="tgz";
my $dsn = "dbi:Sybase:server=SS_MY_DB;database=$database";
my $user="sa";
my $auth="123456";

sub urlhandler {
	#init logger
	my $logger = Log::Log4perl->get_logger();

	#my $r = shift;
	#my $url = $r->uri;
	my $url = "http://pic11.shangpin.com/e/s/15/04/17/20150417165117999215-960-470.jpg";

	#1.reg test url rule
	if($url =~ /^http:\/\/pic\d+?\.shangpin\.com(\/[a-z]{1}\/[a-z]{1}\/)\d{2}\/\d{2}\/\d{2}\/(\d{20})\-(\d{3})\-(\d{3})\.(jpg|png)$/){
		print "test true\n";
		print "$1\n";
		print "$2\n";
		print "$3\n";
		print "$4\n";
		print "$5\n";
		$logger->info("test true");

		#2.test true, first from memcached get cached url and redirect
		#my $cache = Cache::Memcached->new(servers => [$memcached_servers]);
		#my $real_url = $cache->get();

		my $table_name;
		#get sqlserver table name
		if($1 eq "/e/s/") {
			$table_name = "es";
			print "$table_name\n";
		} else if ($1 eq "/e/s/") {

		} else if($1 eq "/e/s/") {

		}

		#declare sqlserver conn

		#get sqlserver url monitor real url and add cached to memcached
		
	} else {
		print "test false\n";
		$logger->info("test false");
	}
}

urlhandler();