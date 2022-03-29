#!/usr/bin/perl
use strict;
use warnings;

my $in_file_name = $ARGV[0];
my $out_file_name_with_fstplot = $ARGV[1];
my $out_file_name_without_fstplot = $ARGV[2];
my $out_with_fstplot = "";
my $out_without_fstplot = "Chromosomes/contigs with less than or equal to 100 and more or equal to 100,000 variants\n";
my $line;
my %chr_hash = ();

my $l = 1;
my $chr_no = 1;
my $previous_chr = "";
open(my $fin, '<', $in_file_name) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(/\t/, $line);
  if ($l == 1) {
    $chr_hash{$chr_no}{$fields[0]}{$fields[1]} = 1;
    $previous_chr = "$fields[0]";
  } else {
    if ("$fields[0]" ne $previous_chr) {
      $chr_no += 1;
      $previous_chr = "$fields[0]";
    }
    $chr_hash{$chr_no}{$fields[0]}{$fields[1]} = 1;
  }
  $l++; 
}
close $fin;

my $var_no = 0;
foreach my $chr_no (sort bynumber keys %chr_hash){
  foreach my $chr_name (keys %{$chr_hash{$chr_no}}){
    $var_no = 0;
    foreach my $var (keys %{$chr_hash{$chr_no}{$chr_name}}){
      $var_no++; 
    }
    if ($var_no >= 100 and $var_no <= 100000) {
      $out_with_fstplot .= $chr_name." ".$var_no."\n";
    } else {
      $out_without_fstplot .= $chr_name." ".$var_no."\n";
    }
  }
}

sub bynumber{
    $a <=> $b;
}

open (my $fout, q{>}, $out_file_name_with_fstplot) or die($!);
print $fout $out_with_fstplot;
close $fout;

open (my $fout2, q{>}, $out_file_name_without_fstplot) or die($!);
print $fout2 $out_without_fstplot;
close $fout2;

1;
