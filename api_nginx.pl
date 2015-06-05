#!/usr/bin/perl -w

package md5;

use nginx;
use strict;
use Digest::MD5 qw(md5_hex);
use Log::Log4perl;

#init logger
Log::Log4perl->init("/log/log4perl.conf");
 
 sub handler {
	#init logger
	my $logger = Log::Log4perl->get_logger();

	my $sp_version = 270;
	my $al_version = 270;
 	my %url_hash = (
 		"/api/userbuyinfo" => "",
 		"/mapi/couponGroup" => "",
 		"/mapi/activateCoupon" => "",
 		"/mapi/queryGiftCardStatus" => "",
 		"/api/orderList" => "",
 		"/api/orderDetail" => "",
 		"/api/confirmSettlement" => "",
 		"/api/updateconfirmorderinfo" => "",
 		"/api/submitOrder" => "",
 		"/api/payOrderNew" => "",
 		"/api/modifyPayOrder" => "",
 		"/api/getaddr" => "",
 		"/api/editaddr" => "",
 		"/api/checkUser" => "",
 		"/api/sendsmscode" => "",
 		"/api/verifysmscode" => "",
 		"/api/setGiftCartPwd" => "",
 		"/api/cardRecharge" => "",
 		"/api/apiv2/giftCardRecordList" => "",
 		"/api/apiv2/giftCardBuy" => "",
 		"/api/apiv2/giftCardElectronicRecharge" => "",
 		"/api/apiv2/giftCardRechargePasswd" => "",
 		"/api/payGiftCardNew" => "",
 		"/api/buyNow" => "",
 		"/api/modifyOrderInfo" => ""
 	);
 	my $r = shift;
	#my $p = $r->header_in("p");
 	#my $ver = $r->header_in("ver");
 	#my $userid = $r->header_in("userid");
 	#my $sign = $r->header_in("sign");
 	my $current_url = $r->uri;
 	my $request = $r->args;
	my $p = "2";
 	my $ver = "2.6.1";
 	my $userid = "43087115F6EDFC293E14C9C036C3F885";
 	my $sign = "6d342452c6e225923fac02f372e4f724";
 	#my $current_url = "/user/find";
	#my $request = "manual=true&model=iPhone%20Simulator&ver=2.7.2";

	$logger->info("p:".$p."ver:".$ver."userid:".$userid.",sign:".$sign.",current_url:".$current_url.",request:".$request);

 	#compare current_url url
 	if(!exists($url_hash{$current_url})) {
		$logger->info("!exists:".$current_url);
		return OK;
 		#return $current_url."?".$request;
 	}

	#compare p and ver
	my $version = 0;
	if ($p eq "2") {
		$version = $sp_version;
	} elsif ($p eq "102") {
		$version = $al_version;
	}
	print "version:".$version."\n";
	$ver =~ s/\.//g;
	$logger->info("version:".$version.",ver:".$ver);
	if ($ver < $version) {
		$logger->info("ver < version");
		return OK;
	}
	$logger->info("version < ver");

	my @querys = split(/&/, $request);
	my %query_hash;
	foreach my $query (@querys) {
		my @key_value = split(/=/, $query);
		$query_hash{$key_value[0]} = !$key_value[1] ? "" : $key_value[1];
	}

	my $request_sort = "";
	my $i = 0;
	my @sort_values = sort(keys %query_hash);
	foreach my $key (@sort_values) {
		if ($i != 0) {
			$request_sort .= "&";
		}
		my $value = $query_hash{$key};
		$request_sort .= $key."=".$value;
		$i++;
	}
	$request_sort .= "&signKey=".$userid;

	$logger->info("md5 url : ".$request_sort);
	my $md5result = md5_hex($request_sort);
	$logger->info("md5result : ".$md5result);
	if($md5result eq $sign) {
		$logger->info("sign true : ".$current_url."?".$request);
 		return OK;
	} else {
		$logger->info("sign false : ".$current_url."?".$request);
 		return DECLINED;
	}
 }

 1;