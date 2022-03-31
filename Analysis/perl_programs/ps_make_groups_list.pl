#!/usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

my $clustering_flag = $ARGV[0];
my $fam_file_name = $ARGV[1];
my $groups_file_name = $ARGV[2];
my $out_file_name = $ARGV[3];
my $out_file_name_orig = $ARGV[4];
my $out_file_name_full = $ARGV[5];
my $out_file_name_matching = $ARGV[6];

my $out = "#IID    CATEGORY\n";
my $out_orig = "IID    CATEGORY\n";
my $out_full = "";
my $line;
my $line2;
my @exist_sample_id_arr = ();
my @sample_id_arr = ();
my @group_id_arr = ();
my %group_hash = ();
my $sample_id_col_number = 0;
my $group_id_col_number = 0;
my $sam_id_exist_flag = "no";
my $gr_id_exist_flag = "no";
my $error_flag = 0;
my $id_str = "";
my $group_str = "";
my $numeric_flag = 0;

open(my $fin, '<', $fam_file_name) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(" ", $line);
  push(@exist_sample_id_arr, $fields[1]); 
}
close $fin;

if ($clustering_flag == 1) {
  open(my $fin2, '<', $groups_file_name) or die($!);
  while(defined ($line2 = <$fin2>)){
    chomp ($line2);
    my @fields = split(" ", $line2);
    push(@sample_id_arr, $fields[1]); 
    push(@group_id_arr, $fields[2]); 
    $group_hash{$fields[2]} = 1;
  }
  close $fin2;
} elsif ($clustering_flag == 0) {
  my $l = 1;
  open(my $fin3, '<', $groups_file_name) or die($!);
  while(defined ($line2 = <$fin3>)){
    chomp ($line2);
    my @fields = split(" ", $line2);
    if ($l == 1) {
      for (my $i=0; $i < @fields; $i++ ) {
        if ($fields[$i] eq "SAMPLE_ID") {
          $sample_id_col_number = $i;
          $sam_id_exist_flag = "yes";
        } elsif ($fields[$i] eq "GROUP_ID") {
          $group_id_col_number = $i;
          $gr_id_exist_flag = "yes";
        }
      }  
    } else {
      if ($sam_id_exist_flag eq "yes" and $gr_id_exist_flag eq "yes") {
        $id_str = "";
        $group_str = "";
        $id_str = $fields[$sample_id_col_number];
        $group_str = $fields[$group_id_col_number];
        if ($id_str ne "" and $group_str ne "") {
          for (my $j=0; $j < @exist_sample_id_arr; $j++ ) {
            if ($id_str eq $exist_sample_id_arr[$j]) {
              push(@sample_id_arr, $id_str); 
              push(@group_id_arr, $group_str); 
              $group_hash{$group_str} = 1;
              if (looks_like_number($group_str)) {
                $numeric_flag = 1;
              }
            }
          }  
        } else {
          $error_flag = 1; 
        }
      } else {
        $error_flag = 1; 
      }
    }  
    $l++;
  }
  close $fin3;
}

my @group_names_unique_unsorted = ();
my @group_names_unique = ();
@group_names_unique_unsorted = keys(%group_hash);

if ($clustering_flag == 1) {
  @group_names_unique = sort { $a <=> $b } @group_names_unique_unsorted;
} elsif ($clustering_flag == 0) {
  @group_names_unique = sort { $a cmp $b } @group_names_unique_unsorted;
}

if (($#group_names_unique + 1) < 2) {
  $error_flag = 1; 
}

if ($error_flag == 0) {
  my $id_gr_str = "";
  my $id_gr_str_orig = "";
  my $id_gr_str_full = "";
  for (my $j=0; $j < @exist_sample_id_arr; $j++ ) {
    $id_gr_str = "";
    $id_gr_str_orig = "";
    $id_gr_str_full = "";
    for (my $i=0; $i < @sample_id_arr; $i++ ) {
      if ($exist_sample_id_arr[$j] eq $sample_id_arr[$i]) {
        for (my $k=0; $k < @group_names_unique; $k++ ) {
          if ($group_id_arr[$i] eq $group_names_unique[$k]) {
            if ($clustering_flag == 1) {
              $id_gr_str = $sample_id_arr[$i]."	C".$group_id_arr[$i]."\n";
              $id_gr_str_orig = $sample_id_arr[$i]."  ".$k.":C".$group_id_arr[$i]."\n";
              $id_gr_str_full = $sample_id_arr[$i]."	C".$group_id_arr[$i]."  ".$k."\n";
            } elsif ($clustering_flag == 0) {
              if ($numeric_flag == 1) {
                $id_gr_str = $sample_id_arr[$i]."	C".$group_id_arr[$i]."\n";
                $id_gr_str_orig = $sample_id_arr[$i]."  ".$k.":C".$group_id_arr[$i]."\n";
                $id_gr_str_full = $sample_id_arr[$i]."	C".$group_id_arr[$i]."  ".$k."\n";
              } else {
                $id_gr_str = $sample_id_arr[$i]."	".$group_id_arr[$i]."\n";
                $id_gr_str_orig = $sample_id_arr[$i]."  ".$k.":".$group_id_arr[$i]."\n";
                $id_gr_str_full = $sample_id_arr[$i]."	".$group_id_arr[$i]."  ".$k."\n";
              }
            } 
          }
        }
      }
    }
    if ($id_gr_str ne "" and $id_gr_str_orig ne "" and $id_gr_str_full ne "") {
      $out .= $id_gr_str;
      $out_orig .= $id_gr_str_orig;
      $out_full .= $id_gr_str_full;
    } else {
      $error_flag = 1; 
    } 
  }
}

if ($error_flag == 0) {

  my $out_matching = "";
  for (my $i=0; $i < @group_names_unique; $i++ ) {
    if ($clustering_flag == 1) {
      $out_matching .= "C".$group_names_unique[$i]." ".$i."\n"; 
    } elsif ($clustering_flag == 0) {
      if ($numeric_flag == 1) {
        $out_matching .= "C".$group_names_unique[$i]." ".$i."\n"; 
      } else {
        $out_matching .= $group_names_unique[$i]." ".$i."\n"; 
      } 
    } 
  }
  open (my $fout, q{>}, $out_file_name_matching) or die($!);
  print $fout $out_matching;
  close $fout;

  open (my $fout2, q{>}, $out_file_name) or die($!);
  print $fout2 $out;
  close $fout2;

  open (my $fout3, q{>}, $out_file_name_orig) or die($!);
  print $fout3 $out_orig;
  close $fout3;

  open (my $fout4, q{>}, $out_file_name_full) or die($!);
  print $fout4 $out_full;
  close $fout4;

} elsif ($error_flag == 1) {
  exit;
}

1;
