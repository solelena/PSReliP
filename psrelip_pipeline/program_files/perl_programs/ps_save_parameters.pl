#!/usr/bin/perl
use strict;
use warnings;

my $snp_only_flag = $ARGV[0]; 
my $geno_val = $ARGV[1];
my $maf_val = $ARGV[2];
my $mind_val = $ARGV[3];
my $imputation_flag = $ARGV[4];
my $ld_pruning_flag = $ARGV[5];
my $ld_window_size = $ARGV[6];
my $ld_window_size_units = $ARGV[7];
my $ld_step_size = $ARGV[8];
my $ld_threshold = $ARGV[9];
my $clustering_flag = $ARGV[10];
my $cluster_k = $ARGV[11];
my $sam_another_name_flag = $ARGV[12];
my $samples_no = $ARGV[13];
my $snp_no_all = $ARGV[14];
my $snp_no_af = $ARGV[15];
my $snp_no = $ARGV[16];
my $eigenval_sum = $ARGV[17];
my $plotly_image_format = $ARGV[18];
my $message_flag = $ARGV[19];
my $fst_plot_message = $ARGV[20];
my $out_file_name = $ARGV[21];
my $out;
my $imputation_flag_str = "";
my $ld_pruning_flag_str = "";
my $clustering_flag_str = "";

if($imputation_flag == 1){
  $imputation_flag_str = "yes";
}elsif($imputation_flag == 0){
  $imputation_flag_str = "no";
}

if($ld_pruning_flag == 1){
  $ld_pruning_flag_str = "yes";
}elsif($ld_pruning_flag == 0){
  $ld_pruning_flag_str = "no";
}

if($clustering_flag == 1){
  $clustering_flag_str = "yes";
}elsif($clustering_flag == 0){
  $clustering_flag_str = "no";
}

$out = $snp_only_flag." ".$geno_val." ".$maf_val." ".$mind_val." ".$imputation_flag_str." ".$ld_pruning_flag_str." ".$ld_window_size." ".$ld_window_size_units." ".$ld_step_size." ".$ld_threshold." ".$clustering_flag_str." ".$cluster_k." ".$sam_another_name_flag." ".$samples_no." ".$snp_no_all." ".$snp_no_af." ".$snp_no." ".$eigenval_sum." ".$plotly_image_format." ".$message_flag." ".$fst_plot_message."\n"; 

open (my $fout, q{>}, $out_file_name) or die($!);
print $fout $out;
close $fout;

1;
