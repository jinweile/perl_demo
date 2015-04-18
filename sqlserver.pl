#!/usr/bin/perl -w
use DBI;
use DBD::Sybase;
  
my $database="tgz";
my $user="sa";
my $auth="123456";
  
# BEGIN{
# 	$ENV{SYBASE} = "/usr/local";
# }
  
# Connect to the SQL Server Database
my $dbh = DBI->connect("dbi:Sybase:server=SS_MY_DB;database=$database",
	$user,
	$auth,
	{RaiseError => 1, AutoCommit => 1}
) || die "Database connection not made: $DBI::errstr";
$sth = $dbh->prepare("select top 10 * from [Customers]");#准备
$sth->execute();#执行
while(@ary = $sth->fetchrow_array()){
	print join("\t",@ary),"\n";#打印抽取结果
}
$sth->finish;#结束句柄
$dbh->disconnect;#断开