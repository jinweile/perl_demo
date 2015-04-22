#!/usr/bin/perl -w

use Data::Dumper;
use DBI;
use DBD::Sybase;
use Cache::Memcached;
use Switch;

sub hand {
	my @pic_wid = (0,140,174,320,383,640,800);
	my @user_pic_wid = (0,140);
	my @sys_pic_wid = (0,140);
	my $temp_wid = "333";
	my $file_path = "";
	foreach $wid (@pic_wid) {
		if($temp_wid < $wid){
			switch($wid) {
				case 0 { $file_path = "FilePath0"; print "0\n"; }
				case 140 { $file_path = "FilePath1"; print "140\n"; }
				case 174 { $file_path = "FilePath2"; print "174\n"; }
				case 320 { $file_path = "FilePath3"; print "320\n"; }
				case 383 { $file_path = "FilePath4"; print "383\n"; }
				case 640 { $file_path = "FilePath5"; print "640\n"; }
				case 800 { $file_path = "FilePath6"; print "800\n"; }
			}
			last;
		}
	}
	if($file_path eq ""){
		$file_path = "FilePath6";
		print "ddddd\n";
	}
	print $file_path."\n";
}

hand();