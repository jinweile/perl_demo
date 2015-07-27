#!/usr/bin/perl -w
use DBI;
use DBD::Sybase;
  
my $database="ComBeziPic";
my $user="writeuser";
my $auth="write\@520";
  
# BEGIN{
# 	$ENV{SYBASE} = "/usr/local";
# }
  
# Connect to the SQL Server Database
my $dbh = DBI->connect("dbi:Sybase:server=fastdfs;database=$database",
	$user,
	$auth,
	{RaiseError => 1, AutoCommit => 1}
) || die "Database connection not made: $DBI::errstr";


my $sql = "select * from ProductPic where PictureFileNo = '120100428111950734301'";
my $item = $dbh->selectrow_hashref($sql);
$dbh->disconnect;
if (!$item) {
	print "exists item\n";
} else {
	print "not exists\n";
}

# if(defined $item->{"FilePath0"}){
# 	print "exists FilePath0\n";
# } else {
# 	print "not FilePath0\n";
# }



#$sth = $dbh->prepare("select * from $table_name where PictureFileNo = '0001'");#准备
# $sth->execute();#执行
# while(@ary = $sth->fetchrow_array()){
# 	print join("\t",@ary),"\n";#打印抽取结果
# }
# $sth->finish;#结束句柄
# $dbh->disconnect;#断开