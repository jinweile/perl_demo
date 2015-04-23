#!/usr/bin/perl -w

use Data::Dumper;
use DBI;
use DBD::Sybase;
use Cache::Memcached;
use Switch;

	use Data::Dumper;
	use DBI;
	use DBD::Sybase;
	use Cache::Memcached;

	sub hander {
		my @pic_wid = (0,140,174,320,383,640,800);
		my @user_pic_wid = (0,140);
		my @sys_pic_wid = (0,140);
		my @memcached_servers = ("localhost:11211");
		my $database="ComBeziPic";
		my $dsn = "dbi:Sybase:server=fastdfs;database=$database";
		my $user="writeuser";
		my $auth="write\@520";
		my $url = "/e/u/15/04/17/20130828174558463186-0-470.jpg";
		if($url =~ /^(\/[a-z]{1}\/[a-z]{1}\/)\d{2}\/\d{2}\/\d{2}\/(\d{20})\-(\d+?)\-(\d+?)\.[a-zA-Z]+?$/){
			print "true\n";
			my $file_path = "";
			my $index = 0;
			my @temp_array;
			if($1 eq "/f/p/") {
				@temp_array = @pic_wid;
			} elsif ($1 eq "/e/u/") {
				@temp_array = @user_pic_wid;
			} elsif($1 eq "/e/s/") {
				@temp_array = @sys_pic_wid;
			}
			my $array_len = @temp_array;
			$array_len = $array_len - 1;
			foreach $wid (@temp_array) {
				if($3 <= $wid){
					$file_path = "FilePath".$index;
					last;
				}
				$index++;
			}
			if($file_path eq ""){
				$file_path = "FilePath0";
			}
			print $file_path."\n";
			my $cached_key = "fastdfs_".$1."_".$2;
			my $cache = Cache::Memcached->new(servers => [@memcached_servers]);
			my $real_url = $cache->get($cached_key);
			if($real_url) {
				print $real_url->{$file_path}."\n";
				return $real_url->{$file_path};
			}
			my $table_name;
			print $1."\n";
			if($1 eq "/f/p/") {
				$table_name = "ProductPic";
			} elsif ($1 eq "/e/u/") {
				$table_name = "UserPic";
			} elsif($1 eq "/e/s/") {
				$table_name = "SystemPic";
			}
			my $sql = "select * from $table_name where PictureFileNo = '$2'";
			print $sql."\n";
			my $dbh = DBI->connect($dsn, $user, $auth, {RaiseError => 1, AutoCommit => 1}) 
					|| die "Database connection not made: $DBI::errstr";
			my $item = $dbh->selectrow_hashref($sql);
			$dbh->disconnect;
			$cache->set($cached_key, $item, 3600 * 24 * 30);
			$cache->disconnect_all;
			return $item->{$file_path};
		} else {
			print "false\n";
			return $url;
		}
	}

hander();