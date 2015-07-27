#!/usr/bin/perl -w

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
		#my $r = shift;
		my $url = "/f/p/w/15/03/27/20141016171257493270-210-280.jpg";
		if($url =~ /^(\/[a-z]{1}\/[a-z]{1}\/[a-z]{0,1}\/{0,1})\d{2}\/\d{2}\/\d{2}\/(\d{20})\-(\d+?)\-(\d+?)\.[a-zA-Z]+?$/){
			my $file_path = "";
			my $index = 0;
			my @temp_array;
			print $1."\n";
			if($1 eq "/f/p/" || $1 eq "/f/p/w/") {
                                		@temp_array = @pic_wid;
                        		} elsif ($1 eq "/e/u/" || $1 eq "/e/u/w/") {
				@temp_array = @user_pic_wid;
			} elsif ($1 eq "/e/s/" || $1 eq "/e/s/w/") {
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
			my $cached_key = "fastdfs_".$1."_".$2;
			my $cache = Cache::Memcached->new(servers => [@memcached_servers]);
			my $real_url = $cache->get($cached_key);
			if($real_url) {
				print "exists cached\n";
				return $real_url->{$file_path};
			}
			my $table_name;
			if($1 eq "/f/p/") {
				$table_name = "ProductPic";
			} elsif ($1 eq "/e/u/") {
				$table_name = "UserPic";
			} elsif($1 eq "/e/s/") {
				$table_name = "SystemPic";
			}  elsif ($1 eq "/f/p/w/") {
				$table_name = "ProductPicWebp";
			} elsif ($1 eq "/e/u/w/") {
				$table_name = "UserPicWebp";
			} elsif ($1 eq "/e/s/w/") {
				$table_name = "SystemPicWebp";
			}
			print "1:".$table_name."\n";
			my $sql = "select * from $table_name where PictureFileNo = \'$2\'";
			my $dbh = DBI->connect($dsn, $user, $auth, {RaiseError => 1, AutoCommit => 1}) 
					|| die "Database connection not made: $DBI::errstr";
			my $item = $dbh->selectrow_hashref($sql);
			my $pic_id = $2;
			if (!$item && $1 =~ /^.+?\/w\/$/) {
				$table_name =~ s/Webp//g;
				print "2:".$table_name."\n";
				$sql = "select * from $table_name where PictureFileNo = \'$pic_id\'";
				$item = $dbh->selectrow_hashref($sql);
			}
			$dbh->disconnect;
			if($item){
				$cache->set($cached_key, $item, 3600 * 24 * 30);
			}
			$cache->disconnect_all;
			return $item->{$file_path};
		} else {
			print "not match\n";
			return $url;
		}
	}

print hander()."\n";