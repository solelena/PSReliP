#!/usr/bin/perl
use strict;
use warnings;

my $in_file_name = $ARGV[0];
my @fst_var_files_arr = ();
my $line;

my $l = 1;
open(my $fin, '<', $in_file_name) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  if ($l > 1) {
    my @fields = split(" ", $line);
    my $fst_file_name = $fields[0].".".$fields[1].".fst.var";
    push(@fst_var_files_arr, $fst_file_name);
  }
  $l++;
}
close $fin;

print "@fst_var_files_arr\n";

1;
