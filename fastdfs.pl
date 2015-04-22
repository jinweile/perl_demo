#!/usr/bin/perl -w

package fastdfs;

use strict;
use Data::Dumper;
use DBI;
use DBD::Sybase;
use Cache::Memcached;
use Log::Log4perl;
use nginx;

#init logger
Log::Log4perl->init("/log/log4perl.conf");

#declare memcached server list
my @memcached_servers = ("localhost:11211");

#declare sqlserver
my $database="ComBeziPic";
my $dsn = "dbi:Sybase:server=fastdfs;database=$database";
my $user="writeuser";
my $auth="write\@520";

sub urlhandler {
	#init logger
	my $logger = Log::Log4perl->get_logger();

	my $r = shift;
	my $url = $r->uri;
	$logger->info("url=========".$url);
	#my $url = "/e/s/15/04/17/20100428112749234441-960-470.jpg";

	#1.reg test url rule
	if($url =~ /^(\/[a-z]{1}\/[a-z]{1}\/)\d{2}\/\d{2}\/\d{2}\/(\d{20})\-(\d{3})\-(\d{3})\.(jpg|png)$/){
		# print "$1\n";
		# print "$2\n";
		# print "$3\n";
		# print "$4\n";
		# print "$5\n";
		$logger->info("test true");

		#2.test true, first from memcached get cached url and redirect
		my $cached_key = "fastdfs_".$1."_".$2;
		my $cache = Cache::Memcached->new(servers => [@memcached_servers]);
		my $real_url = $cache->get($cached_key);
		if($real_url) {
			$r->internal_redirect($real_url->{'FilePath0'});
			#$r->internal_redirect("/index.html");
			return OK;
		} 

		#get sqlserver url monitor real url
		my $table_name;
		#get sqlserver table name
		if($1 eq "/f/p") {
			$table_name = "ProductPic";
		} elsif ($1 eq "/e/u") {
			$table_name = "UserPic";
		} elsif($1 eq "/e/s/") {
			$table_name = "ProductPic";
		}
		print "$table_name\n";
		my $sql = "select * from $table_name where PictureFileNo = '$2'";
		#declare sqlserver conn
		my $dbh = DBI->connect($dsn, $user, $auth, {RaiseError => 1, AutoCommit => 1}) 
				|| die "Database connection not made: $DBI::errstr";
		my $item = $dbh->selectrow_hashref($sql);
		$dbh->disconnect;

		#add cached to memcached
		$cache->set($cached_key, $item, 3600 * 24 * 30);
		$cache->disconnect_all;
		$r->internal_redirect($item->{'FilePath0'});
		return OK;
	} else {
		$logger->info("test false");
		return DECLINED;
	}
}
1;

#print urlhandler()."\n";