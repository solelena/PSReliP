#!/usr/bin/perl
use strict;
use warnings;

my $in_file_name = $ARGV[0];
my $out_file_name = $ARGV[1];
my $out;
my $line;

open(my $fin, '<', $in_file_name) or die($!);
my $l = 1;
while(defined ($line = <$fin>)){
  if ($l == 1) {
    $line =~ s/#//;
    $out = $line;
  } else {  
    $out .= $line;
  }
  $l++;
}
close $fin;

open (my $fout, q{>}, $out_file_name) or die($!);
print $fout $out;
close $fout;

1;
