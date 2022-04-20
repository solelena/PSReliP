#!/usr/bin/perl
use strict;
use warnings;

my $sam_from_user_file_name = $ARGV[0];
my $out_file_name = $ARGV[1];

my $out;
my $line;
my $col_number = 0;
my $sam_id_exist_flag = "no";
my $error_flag = 0;

my $l = 1;
open(my $fin, '<', $sam_from_user_file_name) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(" ", $line);
  if ($l == 1) { 
    for (my $i=0; $i < @fields; $i++ ) {
      if ($fields[$i] eq "SAMPLE_ID") {
        $col_number = $i;
        $sam_id_exist_flag = "yes";
      }
    }
  } else {
    if ($sam_id_exist_flag eq "yes") {
      my $id_str = $fields[$col_number];
      if ($id_str ne "") {
        $out .= $id_str."\n";
      } else {
        $error_flag = 1; 
      }
    } else {
      $error_flag = 1; 
    }
  }
  $l++;
}
close $fin;

if ($error_flag == 0) {
  open (my $fout, q{>}, $out_file_name) or die($!);
  print $fout $out;
  close $fout;
} elsif ($error_flag == 1) {
  exit;
}

1;
