#!/usr/bin/perl
use strict;
use warnings;

my $fam_file_name = $ARGV[0];
my $samples_names_file_name = $ARGV[1];
my $out_file_name = $ARGV[2];

my $out;
my $line;
my $line2;
my @sample_id_arr = ();
my @smp_name_arr = ();
my $id_col_number;
my $name_col_number;
my $sam_id_exist_flag = "no";
my $sam_name_exist_flag = "no";
my $error_flag = 0;
my $id_str = "";
my $name_str = "";

my $l = 1;
open(my $fin, '<', $samples_names_file_name) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(" ", $line);
  if ($l == 1) {
    for (my $i=0; $i < @fields; $i++ ) {
      if ($fields[$i] eq "SAMPLE_ID") {
        $id_col_number = $i;
        $sam_id_exist_flag = "yes";
      } elsif ($fields[$i] eq "SAMPLE_NAME") {
        $name_col_number = $i;
        $sam_name_exist_flag = "yes";
      }
    }
  } else {
    if ($sam_id_exist_flag eq "yes" and $sam_name_exist_flag eq "yes") {
      $id_str = "";
      $name_str = "";
      $id_str = $fields[$id_col_number];
      $name_str = $fields[$name_col_number];
      if ($id_str ne "" and $name_str ne "") {
        push(@sample_id_arr, $id_str); 
        push(@smp_name_arr , $name_str); 
      }
    } else {
      $error_flag = 1; 
    }
  }
  $l++;
}
close $fin;

if ($error_flag == 0) {
  my $smp_name_str = "";
  open(my $fin2, '<', $fam_file_name) or die($!);
  while(defined ($line2 = <$fin2>)){
    chomp ($line2);
    my @fields = split(" ", $line2);
    $smp_name_str = "";
    for (my $i=0; $i < @sample_id_arr; $i++ ) {
      if ($sample_id_arr[$i] eq $fields[1]) {
        $smp_name_str = $smp_name_arr [$i];
      }
    }
    if ($smp_name_str ne "") {
      $out .= $fields[1]." ".$smp_name_str ."\n";
    } else {
      $out .= $fields[1]." ".$fields[1]."\n";
    }
  }
  close $fin2;
}

if ($error_flag == 0) {
  open (my $fout, q{>}, $out_file_name) or die($!);
  print $fout $out;
  close $fout;
} elsif ($error_flag == 1) {
  exit;
}

1;
