#!/usr/bin/perl
use strict;
use warnings;

my $in_file_name = $ARGV[0];
my $in_file_name_groups = $ARGV[1];
my $out_file_name = $ARGV[2];
my @group_name_arr = ();
my @group_nu_arr = ();
my $out = "";
my $line;
my $line2;

open(my $fin, '<', $in_file_name_groups) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(" ", $line);
  push(@group_name_arr, $fields[0]);
  push(@group_nu_arr, $fields[1]);
}
close $fin;

my $l = 1;
open(my $fin2, '<', $in_file_name) or die($!);
while(defined ($line2 = <$fin2>)){
  if ($l > 1) {
    chomp ($line2);
    my $group1_nu = "";
    my $group2_nu = "";
    my @fields = split(" ", $line2);
    for (my $i=0; $i < @group_name_arr; $i++ ) {
      if ($group_name_arr[$i] eq $fields[0]) {
        $group1_nu = $group_nu_arr[$i];
      } elsif ($group_name_arr[$i] eq $fields[1]) {
        $group2_nu = $group_nu_arr[$i];
      }
    }
    $out .= $fields[0]." ".$fields[1]." ".$fields[2]." ".$group1_nu." ".$group2_nu."\n"; 
  }
  $l++;
}
close $fin2;

open (my $fout, q{>}, $out_file_name) or die($!);
print $fout $out;
close $fout;

1;
