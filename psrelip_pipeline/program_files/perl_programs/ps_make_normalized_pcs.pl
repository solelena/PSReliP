#!/usr/bin/perl
use strict;
use warnings;

my $eigenvectors_file_name = $ARGV[0];
my $eigenvalues_file_name = $ARGV[1];
my $out_file_name = $ARGV[2];
my $out;
my $line;

my $pc1_norm = 0; 
my $pc2_norm = 0; 
my $pc3_norm = 0; 
my $pc4_norm = 0; 
my $pc5_norm = 0; 
my $pc6_norm = 0; 
my $pc7_norm = 0; 
my $pc8_norm = 0; 
my $pc9_norm = 0; 
my $pc10_norm = 0; 
my @iid_arr = ();
my @pc1_arr = ();
my @pc2_arr = ();
my @pc3_arr = ();
my @pc4_arr = ();
my @pc5_arr = ();
my @pc6_arr = ();
my @pc7_arr = ();
my @pc8_arr = ();
my @pc9_arr = ();
my @pc10_arr = ();
my @eigenvalues = ();

open(my $fin, '<', $eigenvectors_file_name) or die($!);
my $l = 1;
while(defined ($line = <$fin>)){
  if ($l > 1) {
    chomp ($line);
    my @fields = split(" ", $line);
    push(@iid_arr, $fields[0]);
    push(@pc1_arr, $fields[1]);
    push(@pc2_arr, $fields[2]);
    push(@pc3_arr, $fields[3]);
    push(@pc4_arr, $fields[4]);
    push(@pc5_arr, $fields[5]);
    push(@pc6_arr, $fields[6]);
    push(@pc7_arr, $fields[7]);
    push(@pc8_arr, $fields[8]);
    push(@pc9_arr, $fields[9]);
    push(@pc10_arr, $fields[10]);
  }
  $l++; 
}
close $fin;

open(my $fin2, '<', $eigenvalues_file_name) or die($!);
while(defined ($line = <$fin2>)){
  chomp ($line);
  push(@eigenvalues, $line);
}
close $fin2;

$out = "IID	PC1	PC2	PC3	PC4	PC5	PC6	PC7	PC8	PC9	PC10\n";

for (my $i=0; $i < @iid_arr; $i++ ){
  $pc1_norm = 0; 
  $pc2_norm = 0; 
  $pc3_norm = 0; 
  $pc4_norm = 0; 
  $pc5_norm = 0; 
  $pc6_norm = 0; 
  $pc7_norm = 0; 
  $pc8_norm = 0; 
  $pc9_norm = 0; 
  $pc10_norm = 0; 
  $pc1_norm = $pc1_arr[$i] * sqrt($eigenvalues[0]); 
  $pc2_norm = $pc2_arr[$i] * sqrt($eigenvalues[1]); 
  $pc3_norm = $pc3_arr[$i] * sqrt($eigenvalues[2]); 
  $pc4_norm = $pc4_arr[$i] * sqrt($eigenvalues[3]); 
  $pc5_norm = $pc5_arr[$i] * sqrt($eigenvalues[4]); 
  $pc6_norm = $pc6_arr[$i] * sqrt($eigenvalues[5]); 
  $pc7_norm = $pc7_arr[$i] * sqrt($eigenvalues[6]); 
  $pc8_norm = $pc8_arr[$i] * sqrt($eigenvalues[7]); 
  $pc9_norm = $pc9_arr[$i] * sqrt($eigenvalues[8]); 
  $pc10_norm = $pc10_arr[$i] * sqrt($eigenvalues[9]); 
  $out .= $iid_arr[$i]."	".$pc1_norm."	".$pc2_norm."	".$pc3_norm."	".$pc4_norm."	".$pc5_norm."	".$pc6_norm."	".$pc7_norm."	".$pc8_norm."	".$pc9_norm."	".$pc10_norm."\n";
}

open (my $fout, q{>}, $out_file_name) or die($!);
print $fout $out;
close $fout;

1;
