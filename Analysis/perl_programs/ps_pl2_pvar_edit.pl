#/usr/bin/perl
use strict;
use warnings;

my $in_file_name = $ARGV[0];
my $out_file_name = $ARGV[1];
my $out;
my $line;
my $line2;
my $header_line_no = 0;

open(my $fin, '<', $in_file_name) or die($!);
my $l = 1;
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(/\t/, $line);
  if ($fields[0] eq "#CHROM") {
    $header_line_no = $l;
    last; 
  }
  $l++;
}
close $fin;

my $bim_col_nu = 0;
if ($header_line_no == 0) {
  open(my $fin2, '<', $in_file_name) or die($!);
  my $l3 = 1;
  my $line3;
  while(defined ($line3 = <$fin2>)){
    if ($l3 == 1) {
      chomp ($line3);
      my @fields = split(/\t/, $line3);
      $bim_col_nu = $#fields + 1;
      last; 
    }
    $l3++;
  }
  close $fin2;
}


open(my $fin3, '<', $in_file_name) or die($!);
my $l2 = 1;
while(defined ($line2 = <$fin3>)){
  if ($header_line_no == 0) {
    chomp ($line2);
    my @fields = split(/\t/, $line2);
    my $variant_id = "";    
    if ($bim_col_nu == 5) {
      $variant_id = $fields[0].":".$fields[2];    
      $out .= $fields[0]."	".$variant_id."	".$fields[2]."	".$fields[3]."	".$fields[4]."\n";
    } elsif ($bim_col_nu == 6) {
      $variant_id = $fields[0].":".$fields[3];    
      $out .= $fields[0]."	".$variant_id."	".$fields[2]."	".$fields[3]."	".$fields[4]."	".$fields[5]."\n";
    }
  } else {
    if ($l2 <= $header_line_no) {
      $out .= $line2;
    } else {
      chomp ($line2);
      my @fields = split(/\t/, $line2);
      my $variant_id = $fields[0].":".$fields[1];    
      my $line_out = $fields[0]."	".$fields[1]."	".$variant_id;
      for (my $i=3; $i <= $#fields; $i++ ) {
        $line_out .= "	".$fields[$i];
      }
      $out .= $line_out."\n";
    } 
  }
  $l2++;
}
close $fin3;

open (my $fout, q{>}, $out_file_name) or die($!);
print $fout $out;
close $fout;

1;
