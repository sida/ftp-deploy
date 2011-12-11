#! /usr/bin/perl

use utf8;
use strict;
use warnings;
use Encode;
use Config::Simple;
use File::HomeDir;
use Cwd;
use Net::FTP;

binmode STDOUT, ":utf8";

my $config_home = File::HomeDir->my_home . '/.upconfig.ini';
my $config_dir = Cwd::getcwd() . '/upconfig.ini';
unless (-e $config_home){
  die $config_home . "がありません\n";
}
unless (-e $config_dir){
  die $config_dir . "がありません\n";
}

my $cfg = new Config::Simple($config_dir);
my $HOST = $cfg->param('HOST');
my $DIR = $cfg->param('DIR');
my @FILES = $cfg->param('FILES');
my $home_cfg = new Config::Simple($config_home);
my $SERVER = $home_cfg->param("$HOST.SERVER");
my $USER = $home_cfg->param("$HOST.USER");
my $PASS = $home_cfg->param("$HOST.PASS");

#start FTP
print "Connect $SERVER\n";
my $ftp = Net::FTP->new($SERVER ,Debug => 0 ,Passive=>1) or die;
$ftp->login($USER, $PASS) or die;
print "Login ok $USER\n";
#カレントディレクトリの変更
$ftp->cwd($DIR) or die("failed chdir $DIR");
#バイナリモード
$ftp->type('I');

foreach my $file(@FILES){
  print "upload: $file\n";
  #ファイルの送信
  $ftp -> put($file,$file);
}

#接続切断
$ftp -> quit();
print "closed";

exit;

