#!/usr/bin/perl
use strict;
use warnings;

my $clusters_in_file_name = $ARGV[0];
my $matrix_in_file_name = $ARGV[1];
my $id_in_file_name = $ARGV[2];
my $groups_no = $ARGV[3];
my $data_type = $ARGV[4];
my $out_file_prefix = $ARGV[5];
my $sam_another_name_flag = $ARGV[6];
my $smp_in_file_name = "";
my $smp_name_out_orig_sort = "";
my $smp_name_out = "";
if ($sam_another_name_flag == 1) {
  $smp_in_file_name = $ARGV[7];
  $smp_name_out_orig_sort = "IID	NAME\n";
  $smp_name_out = "IID	NAME\n";
}
my $matrix_val_out_orig_sort;
my $matrix_val_out;
my $matrix_val_out_ed;
my $iid_out_orig_sort = "FID	IID\n";
my $iid_out = "FID	IID\n";
my $line;

my @in_cl_iid_arr = ();
my @in_cluster_no_arr = ();
open(my $fin, '<', $clusters_in_file_name) or die($!);
while(defined ($line = <$fin>)){
  chomp ($line);
  my @fields = split(" ", $line);
  push(@in_cl_iid_arr, $fields[0]);
  push(@in_cluster_no_arr, $fields[2]);
}
close $fin;

my @in_matrix_rows = ();
open(my $fin2, '<', $matrix_in_file_name) or die($!);
while(defined ($line = <$fin2>)){
  chomp ($line);
  my @fields = split(/\t/, $line);
  push(@in_matrix_rows, \@fields);
}
close $fin2;

my $header_line_flag = "no";
my $col_nu = 0;
my $l2 = 1;
open(my $fin3, '<', $id_in_file_name) or die($!);
while(defined ($line = <$fin3>)){
  if ($l2 == 1) {
    chomp ($line);
    my @fields = split(/\t/, $line);
    $col_nu = $#fields + 1;
    if ($fields[0] eq "#FID" or $fields[0] eq "#IID") {
      $header_line_flag = "yes";
    }
    last;
  }
  $l2++;
}
close $fin3;

my @in_iid_arr = ();
my $l = 1;
open(my $fin4, '<', $id_in_file_name) or die($!);
while(defined ($line = <$fin4>)){
  if ($header_line_flag eq "no") {
    chomp ($line);
    my @fields = split(" ", $line);
    if ($col_nu == 1) {
      push(@in_iid_arr, $fields[0]);
    } else {
      push(@in_iid_arr, $fields[1]);
    }
  } elsif ($header_line_flag eq "yes") {
    if ($l > 1) {
      chomp ($line);
      my @fields = split(" ", $line);
      if ($col_nu == 1) {
        push(@in_iid_arr, $fields[0]);
      } else {
        push(@in_iid_arr, $fields[1]);
      }
    }
  }
  $l++;
}
close $fin4;

my @smp_id_arr = ();
my @smp_name_arr = ();
if ($sam_another_name_flag == 1) {
  open(my $fin_n, '<',  $smp_in_file_name) or die($!);
  while(defined ($line = <$fin_n>)){
    chomp ($line);
    my @fields = split(" ", $line);
    push(@smp_id_arr, $fields[0]);
    push(@smp_name_arr, $fields[1]);
  }
  close $fin_n;
}

my @out_iid_arr;
for (my $i=0; $i < $groups_no; $i++ ) {
  for (my $j=0; $j < @in_cluster_no_arr; $j++ ) {
    if ($in_cluster_no_arr[$j] == $i) {
      push(@out_iid_arr, $in_cl_iid_arr[$j]);
    }  
  }
}

my $ar_size = @in_iid_arr - 1;
my @out_matrix_rows = ();
push @out_matrix_rows, [(0)x$ar_size] for (0..$ar_size);

for(my $m = 0; $m <= $#in_matrix_rows; $m++) 
{    
   for(my $n = 0; $n <= $#in_matrix_rows; $n++) 
   {   
     my $dis_val = 0;   
     $dis_val = $in_matrix_rows[$m][$n];   
     my $sam1 = $in_iid_arr[$m]; 
     my $sam2 = $in_iid_arr[$n]; 
     my $sam1_pos = 0;
     my $sam2_pos = 0;
     for (my $j=0; $j < @out_iid_arr; $j++ ) {
       if ($out_iid_arr[$j] eq $sam1) {
         $sam1_pos = $j;
       } 
       if ($out_iid_arr[$j] eq $sam2) {
         $sam2_pos = $j;
       }
     } 
     $out_matrix_rows[$sam1_pos][$sam2_pos] = $dis_val;
   }   
} 

for(my $i = 0; $i <= $#out_matrix_rows; $i++) 
{    
   for(my $j = 0; $j <= $#out_matrix_rows; $j++) 
   {   
     my $val_ed = 0; 
     if ($i == $j) {
       if ($data_type eq "ibs" or $data_type eq "rel") {
         $val_ed = 1; 
       } elsif($data_type eq "king") {
         $val_ed = $out_matrix_rows[$i][$j]; 
       }
     } else {
       if ($out_matrix_rows[$i][$j] < 0) {
         $val_ed = 0; 
       } elsif ($out_matrix_rows[$i][$j] > 1) {
         $val_ed = 1; 
       } else {
         $val_ed = sprintf("%.3f", $out_matrix_rows[$i][$j]);
       }
     }

     if ($j == 0) {
       $matrix_val_out .= $out_matrix_rows[$i][$j];   
       $matrix_val_out_ed .= $val_ed;   
     } else {
       $matrix_val_out .= "	".$out_matrix_rows[$i][$j];   
       $matrix_val_out_ed .= "	".$val_ed;   
     }
   }   
   $matrix_val_out .= "\n";   
   $matrix_val_out_ed .= "\n";   
} 

for(my $m = 0; $m <= $#in_matrix_rows; $m++)
{
   for(my $n = 0; $n <= $#in_matrix_rows; $n++)
   {
     my $val_os = 0;
     if ($m == $n) {
       if ($data_type eq "ibs" or $data_type eq "rel") {
         $val_os = 1;
       } elsif($data_type eq "king") {
         $val_os = $in_matrix_rows[$m][$n];
       }
     } else {
       if ($in_matrix_rows[$m][$n] < 0) {
         $val_os = 0;
       } elsif ($in_matrix_rows[$m][$n] > 1) {
         $val_os = 1;
       } else {
         $val_os = sprintf("%.3f", $in_matrix_rows[$m][$n]);
       }
     }

     if ($n == 0) {
       $matrix_val_out_orig_sort .= $val_os;
     } else {
       $matrix_val_out_orig_sort .= "  ".$val_os;
     }
   }
   $matrix_val_out_orig_sort .= "\n";
}

for (my $i=0; $i < @out_iid_arr; $i++ ) {
  $iid_out .= "0	".$out_iid_arr[$i]."\n";

  if ($sam_another_name_flag == 1) {
    for (my $j=0; $j < @smp_id_arr; $j++ ) {
      if ($out_iid_arr[$i] eq $smp_id_arr[$j]) {
        $smp_name_out .= $smp_id_arr[$j]."	".$smp_name_arr[$j]."\n";
      }
    }
  }

}

for (my $m=0; $m < @in_iid_arr; $m++ ) {
  $iid_out_orig_sort .= "0	".$in_iid_arr[$m]."\n";

  if ($sam_another_name_flag == 1) {
    for (my $n=0; $n < @smp_id_arr; $n++ ) {
      if ($in_iid_arr[$m] eq $smp_id_arr[$n]) {
        $smp_name_out_orig_sort .= $smp_id_arr[$n]."	".$smp_name_arr[$n]."\n";
      }
    }
  }  

}

open (my $fout, q{>}, $out_file_prefix."_full") or die($!);
  print $fout $matrix_val_out;
close $fout;
 
open (my $fout2, q{>}, $out_file_prefix) or die($!);
  print $fout2 $matrix_val_out_ed;
close $fout2;

if ($sam_another_name_flag == 0) {
  open (my $fout3, q{>}, $out_file_prefix.".id") or die($!);
    print $fout3 $iid_out;
  close $fout3;
} elsif ($sam_another_name_flag == 1) {
  open (my $fout4, q{>}, $out_file_prefix."_smp.list") or die($!);
    print $fout4 $smp_name_out;
  close $fout4;
}

open (my $fout5, q{>}, $out_file_prefix.".orig_sorted") or die($!);
  print $fout5 $matrix_val_out_orig_sort;
close $fout5;

if ($sam_another_name_flag == 0) {
  open (my $fout6, q{>}, $out_file_prefix.".orig_sorted.id") or die($!);
    print $fout6 $iid_out_orig_sort;
  close $fout6;
} elsif ($sam_another_name_flag == 1) {
  open (my $fout7, q{>}, $out_file_prefix."_smp_os.list") or die($!);
    print $fout7 $smp_name_out_orig_sort;
  close $fout7;
}

1;
