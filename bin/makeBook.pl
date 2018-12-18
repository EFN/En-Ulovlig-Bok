#!/usr/bin/perl

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
