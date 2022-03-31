#!/usr/bin/perl
use strict;
use warnings;

my $mess_type = $ARGV[0];
my $out_file_name = $ARGV[1];
my $out;

if ($mess_type eq "chr_num") {
  $out = "The number of chromosomes (NUMBER_OF_CHROMOSOMES parameter) was set to invalid value '0'. The variants of all chromosomes from the VCF file are used.\n"; 
} elsif ($mess_type eq "clus_num") {
  $out = "The number of clusters (CLUSTER_K parameter) was set to invalid value (less than 2). The value for this parameter was reset to '2'.\n"; 
} elsif ($mess_type eq "samples_select") {
  $out = "List of IDs for samples cannot be created from the provided input file. All samples from the VCF file are used.\n"; 
} elsif ($mess_type eq "another_names") {
  $out = "List of names for samples cannot be created from the provided input file. Sample IDs from the VCF file are used.\n"; 
} elsif ($mess_type eq "samples_groups") {
  $out = "There are no valid groups in the provided input file. Cluster analysis (K=2) was performed to group the samples into clusters.\n"; 
}

open (my $fout, q{>>}, $out_file_name) or die($!);
print $fout $out;
close $fout;

1;
