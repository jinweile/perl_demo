#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::Sybase;
use Redis;

#mysql openapi
my $dbh = DBI->connect("DBI:mysql:database=openapi;host=192.168.20.82",
			"root",
			"123456");
my $sth = $dbh->prepare("select a.*,b.SupplierName,c.Url from calllimittimes as a inner join supplier as b on b.SupplierID = a. SupplierID inner join resturl as c on c.RestUrlID = a.RestUrlID");
$dbh->do("SET character_set_client = 'utf8'");
$dbh->do("SET character_set_connection = 'utf8'");
$dbh->do("SET character_set_results= 'utf8'");
$sth->execute();

#sqlserver
my $sqlserver = DBI->connect("dbi:Sybase:server=SS_MY_DB;database=tgz",
				"sa",
				"123456",
				{RaiseError => 1, AutoCommit => 1}
			) || die "Database connection not made: $DBI::errstr";

#redis
my $redis = Redis->new(server => '192.168.20.82:6379');
my $current_time = gettime();
my $current_day = $current_time->{'day'};
my $current_hour = $current_time->{'hour'};
while(my @row = $sth->fetchrow_array()){
	#print $row[7]."\n";
	my $key = "openapi_hincrby_$row[1]_$row[2]_m_".$current_day."_".$current_hour;
	#print $key."\n";
	my @hit = $redis->hgetall($key);
	my $hit_len = @hit;
	#print $hit_len."\n";
	for (my $i = 0; $i < $hit_len; $i += 2){
		print !@hit ? "" : $hit[$i].":".$hit[$i + 1]."\n";
		my $sql = "if not exists (select 1 from hitnum where sid = ? and url = ? and days = ? and hours = ? and minitues = ?) 
				begin
					insert hitnum(sid, sname, url, days, hours , minitues, hits) values(?, ?, ?, ?, ?, ?, ?)
				end
				else
				begin
					update hitnum set hits = ? where sid = ? and url = ? and days = ? and hours = ? and minitues = ?
				end";
		$sqlserver->do($sql, undef, 
				$row[1], $row[8], $current_day, $current_hour, $hit[$i],
				$row[1], $row[7], $row[8], $current_day, $current_hour, $hit[$i], $hit[$i + 1],
				$hit[$i + 1], $row[1], $row[8], $current_day, $current_hour, $hit[$i]);
	}
}
$sth->finish;
$dbh->disconnect;
$sqlserver->disconnect;

sub gettime{
	my $time = shift || (time() - 60 * 60);
	#print $time."\n";
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$year = $year + 1900;
	$mon = ($mon +1 < 10) ? "0".($mon +1) : ($mon +1);
	$mday = ($mday < 10) ? "0".$mday : $mday;
	$hour = ($hour < 10) ? "0".$hour : $hour;
	return {"day" => "$year-$mon-$mday", "hour" => "$hour"};
}