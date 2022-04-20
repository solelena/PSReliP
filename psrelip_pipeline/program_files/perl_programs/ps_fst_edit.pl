#!/usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

my $in_file_name = $ARGV[0];
my $orig_groups = $ARGV[1];
my $in_file_name_groups = $ARGV[2];
my $in_file_name_chrs = $ARGV[3];
my $out_file_prefix = $ARGV[4];
my $out = "CHR_NAME	CHR	ID	POS	OBS_CT	FST\n";
my $line;
my $line2;
my $line3;
my $line4;
my @chr_name_arr = ();
my %chr_hash = ();
my %contigs_hash = ();
my $chr_exist_flag = "no";
my $contigs_exist_flag = "no";

open(my $fin, '<', $in_file_name_chrs) or die($!);
while(defined ($line4 = <$fin>)){
  chomp ($line4);
  my @fields = split(" ", $line4);
  push(@chr_name_arr, "$fields[0]");
}
close $fin;

my $l2 = 1;
my $contig_no = 1;
my $previous_contig = "";
open(my $fin2, '<', $in_file_name) or die($!);
while(defined ($line2 = <$fin2>)){
  if ($l2 > 1) {
    chomp ($line2);
    my @fields = split(/\t/, $line2);
    for (my $i=0; $i < @chr_name_arr; $i++ ) {
      if ($chr_name_arr[$i] eq "$fields[0]") { 
        if (looks_like_number($fields[0])) {
          $chr_hash{$fields[0]} = 1;
          $chr_exist_flag = "yes";
        } else {
          if ($previous_contig eq "") {
            $contigs_exist_flag = "yes";
            $previous_contig = $fields[0];
          }
          if ($fields[0] ne $previous_contig) {
            $contig_no += 1;
            $previous_contig = $fields[0];
          }
          $contigs_hash{$contig_no}{$fields[0]} = 1;
        }
      }
    }
  }
  $l2++;
}
close $fin2;

my $max_chr_no = 0;
my @chr_nu_unique = ();
if ($chr_exist_flag eq "yes") {
  @chr_nu_unique = keys(%chr_hash);
  @chr_nu_unique = sort {$b <=> $a} @chr_nu_unique;
  if ($#chr_nu_unique >= 0) {
    $max_chr_no = $chr_nu_unique[0];
  }
}

my @contigs_names_unique = ();
if ($contigs_exist_flag eq "yes") {
  foreach my $con_no (sort bynumber keys %contigs_hash){
    foreach my $con_name (keys %{$contigs_hash{$con_no}}){
      push(@contigs_names_unique, $con_name);
    }
  }
}

my $l = 1;
open(my $fin3, '<', $in_file_name) or die($!);
while(defined ($line = <$fin3>)){
  if ($l > 1) {
    my @fields = split(" ", $line);
    my $chr_num = 99999;
    if (looks_like_number($fields[0])) {
      if ($chr_exist_flag eq "yes") {
        if (($#chr_nu_unique + 1) >= 1) {
          for (my $j=0; $j < @chr_nu_unique; $j++ ) {
            if ($chr_nu_unique[$j] eq $fields[0]) {
              $chr_num = $fields[0];
            }
          }
        }
      }
    } else {
      if ($contigs_exist_flag eq "yes") {
        if (($#contigs_names_unique + 1) >= 1 ) {
          for (my $i=0; $i < @contigs_names_unique; $i++ ) {
            if ($contigs_names_unique[$i] eq $fields[0]) {
              $chr_num = $i + 1 + $max_chr_no;
            }
          }
        }
      }
    }  

    if ($fields[4] ne "nan" and $chr_num != 99999){
      if ($fields[4] < 0){
        $out .= "$fields[0]	".$chr_num."	".$fields[2]."	".$fields[1]."	".$fields[3]."	0\n";
      } else {
        $out .= "$fields[0]	".$chr_num."	".$fields[2]."	".$fields[1]."	".$fields[3]."	".sprintf("%.3f", $fields[4])."\n";
      }
    }
  }
  $l++;
}
close $fin3;

sub bynumber{
    $a <=> $b;
}

my @orig_groups_arr = split(/\./, $orig_groups);
my $group1 = "";
my $group2 = "";

open(my $fin4, '<', $in_file_name_groups) or die($!);
while(defined ($line3 = <$fin4>)){
  my @fields = split(" ", $line3);
  if ($fields[0] eq $orig_groups_arr[0]){
    $group1 = $fields[1];
  } elsif ($fields[0] eq $orig_groups_arr[1]) {
    $group2 = $fields[1];
  }
}
close $fin4;

open (my $fout, q{>}, $out_file_prefix."fst_".$group1."_".$group2.".var") or die($!);
print $fout $out;
close $fout;

1;
