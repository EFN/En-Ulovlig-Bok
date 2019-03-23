#!/usr/bin/perl

sub portopen {
  my $host = $_[0];
  my $port = $_[1];
  #QUICK HACK to check if port is open
  system("nc -z localhost 9222");
  return not $?;
}

my $pid = 0;
if (!portopen("localhost", 9222)) {
  print "Starting chrome instance\n";
  $pid = fork();
  if (not $pid) {
    exec("chromium --headless --remote-debugging-port=9222");
  }
  #Give Chrome a chance to start
  sleep(2);
}


$dir=$ARGV[0];
$baseurl=$ARGV[1];
$papersize=$ARGV[2];
open (URLS, "<", "urls.txt");
$n=0;
while (<URLS>) {
  $_=~s/^\./$baseurl/;
  chomp;
  $out=sprintf "$dir/%03d.pdf", ++$n;
  print $_."\n";
  my @cmd;
  if (0) {
      @cmd = ("wkhtmltopdf", $_,  "$dir/tmp.pdf");
  } elsif (0) {
      @cmd = ("chromium", "--headless", "--disable-gpu",
	      "--print-to-pdf=$dir/tmp.pdf", $_);
  }
  else {
      @cmd = ("bin/print-via-chrome.js", "9222",  $_, "$dir/tmp.pdf");
  }
  system(@cmd);
  @cmd = ("pdfjam", "--outfile", $out,
	      "--papersize", $papersize, "$dir/tmp.pdf");
  system(@cmd);
  unlink("$dir/tmp.pdf");
}

if ($pid) {
  print "Shutting down chrome instance\n";
  kill 'TERM', $pid;
}
