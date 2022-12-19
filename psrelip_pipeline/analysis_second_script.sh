#! /bin/bash
#

CONF_FILE=/home/user/psrelip_pipeline/psrelip.config

if [ -f "$CONF_FILE" ]
then
  source "$CONF_FILE"
else 
  echo "Config file does not exist"
  exit -1
fi

echo "PLINK_HOME=$PLINK_HOME" >&2
echo "PLINK2_HOME=$PLINK2_HOME" >&2

echo "TOOL_INSTALL_DIR=$TOOL_INSTALL_DIR" >&2
echo "WD=$WD" >&2
echo "SAMPLES_ID_FOR_ANA=$SAMPLES_ID_FOR_ANA" >&2

echo "SHINY_APP_DIR=$SHINY_APP_DIR" >&2

echo "EXTRA_CHR_FLAG=$EXTRA_CHR_FLAG" >&2
echo "NUMBER_OF_CHROMOSOMES=$NUMBER_OF_CHROMOSOMES" >&2
echo "SNP_ONLY_FLAG=$SNP_ONLY_FLAG" >&2
echo "GENO_VAL=$GENO_VAL" >&2
echo "MAF_VAL=$MAF_VAL" >&2
echo "MIND_VAL=$MIND_VAL" >&2
echo "IMPUTATION_FLAG=$IMPUTATION_FLAG" >&2
echo "LD_PRUNING_FLAG=$LD_PRUNING_FLAG" >&2
echo "LD_WINDOW_SIZE=$LD_WINDOW_SIZE" >&2
echo "LD_WINDOW_SIZE_UNITS=$LD_WINDOW_SIZE_UNITS" >&2
echo "LD_STEP_SIZE=$LD_STEP_SIZE" >&2
echo "LD_THRESHOLD=$LD_THRESHOLD" >&2
echo "CLUSTERING_FLAG=$CLUSTERING_FLAG" >&2
echo "CLUSTER_K=$CLUSTER_K" >&2
echo "SAM_SELECT_FLAG=$SAM_SELECT_FLAG" >&2
echo "SAM_ANOTHER_NAME_FLAG=$SAM_ANOTHER_NAME_FLAG" >&2
echo "PLOTLY_IMAGE_FORMAT=$PLOTLY_IMAGE_FORMAT" >&2
echo "OUTPUT_PREFIX=$OUTPUT_PREFIX" >&2
echo "MAX_MEM_USAGE=$MAX_MEM_USAGE" >&2
echo "MAX_THREADS=$MAX_THREADS" >&2

PERL_PROGRAM_HOME=${TOOL_INSTALL_DIR}/program_files/perl_programs
SHINY_PROGRAM_HOME=${TOOL_INSTALL_DIR}/program_files/shiny_programs

BED_INPUT_FILE=${WD}/bed_files/plink_input_data
ALLELE_FREQ_COUNTS_FILE=${BED_INPUT_FILE}_frc.acount

SAMPLES_NO=0
GROUPS_NO=0
SNP_NO_ALL=0
SNP_NO_AF=0
SNP_NO=0
CHR_CONTIGS_NO=0
MESSAGE_FLAG=0
FST_PLOT_MESSAGE='no' 
EIGENVAL_SUM=0

INPUT_DIR=${WD}/input_files/${OUTPUT_PREFIX}
PRUNED_SET_DIR=${WD}/pruned_subset/${OUTPUT_PREFIX}
BS_OUTPUT_DIR=${WD}/basic_statistics/${OUTPUT_PREFIX}
PSA_OUTPUT_DIR=${WD}/psa_output/${OUTPUT_PREFIX}
FST_OUTPUT_DIR=${WD}/fst_output/${OUTPUT_PREFIX}
KSH_OUTPUT_DIR=${WD}/kinship_output/${OUTPUT_PREFIX}

if [ -d "${INPUT_DIR}" ]
then
  if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b.psam ]
  then
    rm -f "${INPUT_DIR}"/*
  fi 
else
  mkdir -p "${INPUT_DIR}"
fi

if [ "${LD_PRUNING_FLAG}" -eq 1 ]
then
  if [ -d "${PRUNED_SET_DIR}" ]
  then
    if [ -f "${PRUNED_SET_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}".prune.in ]
    then
      rm -f "${PRUNED_SET_DIR}"/*
    fi
  else
    mkdir -p "${PRUNED_SET_DIR}"
  fi
fi

if [ -d "${BS_OUTPUT_DIR}" ]
then
  if [ -f "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_miss.smiss ]
  then
   rm -f "${BS_OUTPUT_DIR}"/*
  fi
else
  mkdir -p "${BS_OUTPUT_DIR}"
fi

if [ -d "${PSA_OUTPUT_DIR}" ]
then
  if [ -f "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.mds ]
  then
    rm -f "${PSA_OUTPUT_DIR}"/*
  fi
else
  mkdir -p "${PSA_OUTPUT_DIR}"
fi

if [ -d "${FST_OUTPUT_DIR}" ]
then
  if [ -f "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst.fst.summary ]
  then
    rm -f "${FST_OUTPUT_DIR}"/*
  fi
else
  mkdir -p "${FST_OUTPUT_DIR}"
fi

if [ -d "${KSH_OUTPUT_DIR}" ]
then
  if [ -f "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs ]
  then
    rm -f "${KSH_OUTPUT_DIR}"/*
  fi
else
  mkdir -p "${KSH_OUTPUT_DIR}"
fi

if [ -d "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}" ]
then
  if [ -f "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/app.R ]
  then
    rm -f "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/*
    rm -f "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/*
  fi
else
  mkdir -p "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data
fi

TIME_START=`date +%s`
echo "Start time: `date '+%Y/%m/%d %H:%M:%S'` Start the analysis stage"

if [ "${EXTRA_CHR_FLAG}" -eq 0 ] && [ "${NUMBER_OF_CHROMOSOMES}" -eq 0 ]
then
  NUMBER_OF_CHROMOSOMES=99
  echo "The number of chromosomes (NUMBER_OF_CHROMOSOMES parameter) was set to invalid value '0'. The variants of all chromosomes from the VCF file are used."
  perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'chr_num' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
  MESSAGE_FLAG=1
fi

if [ "${CLUSTERING_FLAG}" -eq 1 ] && [ "${CLUSTER_K}" -lt 2 ]
then
  CLUSTER_K=2
  echo "The number of clusters (CLUSTER_K parameter) was set to invalid value (less than 2). The value for this parameter was reset to '2'."
  perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'clus_num' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
  MESSAGE_FLAG=1
fi

RANGE_OF_CHROMOSOMES=1-${NUMBER_OF_CHROMOSOMES}

if [ "${SAM_SELECT_FLAG}" -eq 1 ]
then
  perl "${PERL_PROGRAM_HOME}"/ps_make_samples_ids.pl "${SAMPLES_ID_FOR_ANA}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_samples.list
  if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_samples.list ]
  then
    echo "List of samples was created."
  else
    SAM_SELECT_FLAG=0
    echo "List of IDs for samples cannot be created from the ${SAMPLES_ID_FOR_ANA} file. All samples from the VCF file are used."
    perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'samples_select' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
    MESSAGE_FLAG=1
  fi
fi
  
if [ ${SAM_SELECT_FLAG} -eq 1 ]
then
  "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --keep "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_samples.list --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv
  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --sample-counts --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_sc
  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_sc.scount "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_sample_counts.scount
  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --missing sample-only --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_miss
  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_miss.smiss "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_missing.smiss
  SNP_NO_ALL=$( grep -vc '^#' "${INPUT_DIR}/${OUTPUT_PREFIX}_sv.pvar" )

  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --make-just-fam --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv_b
else
  "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --sample-counts --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_sc
  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_sc.scount "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_sample_counts.scount
  "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --missing sample-only --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_miss
  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_miss.smiss "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_missing.smiss
  SNP_NO_ALL=$( grep -vc '^#' "${BED_INPUT_FILE}.pvar" )

  "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --make-just-fam --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv_b
fi

if [ "${SAM_ANOTHER_NAME_FLAG}" -eq 0 ]
then
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv_b.fam "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_samples_info_orig.fam
else
  perl "${PERL_PROGRAM_HOME}"/ps_make_samples_list.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv_b.fam "${SAMPLES_ID_FOR_ANA}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp_orig.list

  if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp_orig.list ]
  then
    cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp_orig.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/smp_orig.list
    echo "List of names for samples was created."
  else
    SAM_ANOTHER_NAME_FLAG=0
    cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv_b.fam "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_samples_info_orig.fam
    echo "List of names for samples cannot be created from the ${SAMPLES_ID_FOR_ANA} file. Sample IDs from the VCF file are used."
    perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'another_names' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
    MESSAGE_FLAG=1
  fi
fi

if [ ${SAM_SELECT_FLAG} -eq 1 ]
then
  if [ "${SNP_ONLY_FLAG}" -eq 1 ]
  then
    if [ "${EXTRA_CHR_FLAG}" -eq 1 ]
    then
      "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --snps-only --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    else
      "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --chr ${RANGE_OF_CHROMOSOMES} --snps-only --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    fi
  else
    if [ "${EXTRA_CHR_FLAG}" -eq 1 ]
    then
      "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    else
      "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv --allow-extra-chr --chr ${RANGE_OF_CHROMOSOMES} --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    fi 
  fi
else
  if [ "${SNP_ONLY_FLAG}" -eq 1 ]
  then
    if [ "${EXTRA_CHR_FLAG}" -eq 1 ]
    then
      "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --snps-only --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    else
      "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --chr ${RANGE_OF_CHROMOSOMES} --snps-only --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads "$MAX_THREADS" --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    fi
  else
    if [ "${EXTRA_CHR_FLAG}" -eq 1 ]
    then
      "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads 8 --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    else
      "${PLINK2_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --chr ${RANGE_OF_CHROMOSOMES} --mind "$MIND_VAL" --geno "$GENO_VAL" --maf "$MAF_VAL" --make-pgen --memory "$MAX_MEM_USAGE" --threads 8 --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b
    fi
  fi
fi
 
"${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --sample-counts --memory "$MAX_MEM_USAGE" --threads 8 --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_af_sc
perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_af_sc.scount "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_sample_counts_af.scount
"${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --missing sample-only --memory "$MAX_MEM_USAGE" --threads 8 --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_af_miss
perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_af_miss.smiss "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_missing_af.smiss
SNP_NO_AF=$( grep -vc '^#' "${INPUT_DIR}/${OUTPUT_PREFIX}_pl2_b.pvar" )

if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv.pvar ]
then
  rm -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_sv*
else
  echo "${INPUT_DIR}/${OUTPUT_PREFIX}_sv files do not exist"
fi

"${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --make-bed --memory "$MAX_MEM_USAGE" --threads 8 --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b

if [ ${SAM_ANOTHER_NAME_FLAG} -eq 0 ]
then
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_samples_info.fam
else
  perl "${PERL_PROGRAM_HOME}"/ps_make_samples_list.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${SAMPLES_ID_FOR_ANA}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	

  if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	 ]
  then
    cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/smp.list	
    echo "List of names for samples was created."
  else
    SAM_ANOTHER_NAME_FLAG=0
    cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_samples_info.fam
    echo "List of names for samples cannot be created from the ${SAMPLES_ID_FOR_ANA} file. Sample IDs from the VCF file are used."
    perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'another_names' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
    MESSAGE_FLAG=1
  fi
fi

if [ "${LD_PRUNING_FLAG}" -eq 1 ]
then

  if [ "${LD_WINDOW_SIZE_UNITS}" = "kb" ]
  then
    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --indep-pairwise "$LD_WINDOW_SIZE" "$LD_WINDOW_SIZE_UNITS" 1 "$LD_THRESHOLD" --memory "$MAX_MEM_USAGE" --threads 8 --out "${PRUNED_SET_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"
  else
    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --indep-pairwise "$LD_WINDOW_SIZE" "$LD_STEP_SIZE" "$LD_THRESHOLD" --memory "$MAX_MEM_USAGE" --threads 8 --out "${PRUNED_SET_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"
  fi
 
  if [ -f "${PRUNED_SET_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}".prune.in ]
  then
    echo "LD pruned variants set was created."
  else
    echo "LD-based variant pruning cannot be performed with selected parameters. Please try less restricted r2 threshold for LD pruning."
    exit
  fi

  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --extract "${PRUNED_SET_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}".prune.in --make-pgen --memory "$MAX_MEM_USAGE" --threads 8 --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b
  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --extract "${PRUNED_SET_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}".prune.in --make-bed --memory "$MAX_MEM_USAGE" --threads 8 --out "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b
   
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b.bim "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.bim
  SAMPLES_NO=$( wc -l <"${INPUT_DIR}/${OUTPUT_PREFIX}_ld${LD_THRESHOLD}_pl_b.fam" )
  SNP_NO=$( grep -vc '^#' "${INPUT_DIR}/${OUTPUT_PREFIX}_ld${LD_THRESHOLD}_pl2_b.pvar" )  
  
  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --het 'cols=+het,+het' --memory "$MAX_MEM_USAGE" --threads 8 --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_het
  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_het.het "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_het.het 
  "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b --allow-extra-chr --ibc --memory "$MAX_MEM_USAGE" --out "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ibc
  cp "${BS_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ibc.ibc "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_ibc.ibc

  if [ "${CLUSTERING_FLAG}" -eq 1 ]
  then
    GROUPS_NO=$CLUSTER_K 
    "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b --allow-extra-chr --cluster --K $GROUPS_NO --mds-plot 10 --memory "$MAX_MEM_USAGE" --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"
    perl "${PERL_PROGRAM_HOME}"/ps_make_groups_list.pl "${CLUSTERING_FLAG}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster2 "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_orig.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list 
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster1 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster1
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster2 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster2
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster3 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster3
  else
    perl "${PERL_PROGRAM_HOME}"/ps_make_groups_list.pl "${CLUSTERING_FLAG}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${SAMPLES_ID_FOR_ANA}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_orig.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list  "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list
    if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list ]
    then
      GROUPS_NO=$( awk '{print $3}' "${INPUT_DIR}/${OUTPUT_PREFIX}_groups_for_sort.list" | sort | uniq | wc -l )
      "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b --allow-extra-chr --cluster --K "$GROUPS_NO" --mds-plot 10 --memory "$MAX_MEM_USAGE" --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"
    else
      GROUPS_NO=2
      "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b --allow-extra-chr --cluster --K $GROUPS_NO --mds-plot 10 --memory "$MAX_MEM_USAGE" --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"
      CLUSTERING_FLAG=1
      perl "${PERL_PROGRAM_HOME}"/ps_make_groups_list.pl ${CLUSTERING_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster2 "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_orig.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list  "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list
      cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster1 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster1
      cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster2 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster2
      cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".cluster3 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster3
      echo "There are no valid groups in the ${SAMPLES_ID_FOR_ANA} file. Cluster analysis (K=2) was performed to group the samples into clusters."
      perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'samples_groups' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
      MESSAGE_FLAG=1
    fi
  fi

  cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}".mds "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_mds_plot.mds
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_names_numbers.list

  if [ ${GROUPS_NO} -le 5 ]
  then
    perl "${PERL_PROGRAM_HOME}"/ps_chr_no_count.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b.bim "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/chr_used_fstplot.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/chr_notused_fstplot.txt
    CHR_CONTIGS_NO=$( wc -l <"${SHINY_APP_DIR}/${OUTPUT_PREFIX}/data/chr_used_fstplot.txt" )

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --fst CATEGORY 'report-variants' --pheno "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list --memory "$MAX_MEM_USAGE" --threads 8 --out "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst
    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst.fst.summary "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_fst.fst.summary
    perl "${PERL_PROGRAM_HOME}"/ps_fst_summary_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst.fst.summary "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.fst.summary

    FST_VAR_FILES=`perl ${PERL_PROGRAM_HOME}/ps_fst_var_files.pl ${FST_OUTPUT_DIR}/${OUTPUT_PREFIX}_ld${LD_THRESHOLD}_fst.fst.summary`
    declare -a FST_VAR_FILES_ARRAY=(${FST_VAR_FILES})
    FST_FILES_ARRAY_LEN=$( grep -vc '^#' "${FST_OUTPUT_DIR}/${OUTPUT_PREFIX}_ld${LD_THRESHOLD}_fst.fst.summary" )

    for (( i = 0; i < $FST_FILES_ARRAY_LEN; i++ ))
    do
      perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst."${FST_VAR_FILES_ARRAY[$i]}" "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_fst."${FST_VAR_FILES_ARRAY[$i]}"
    done

    if [ "${CHR_CONTIGS_NO}" -gt 0 ]
    then
      for (( j = 0; j < $FST_FILES_ARRAY_LEN; j++ ))
      do
        perl "${PERL_PROGRAM_HOME}"/ps_fst_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst."${FST_VAR_FILES_ARRAY[$j]}" "${FST_VAR_FILES_ARRAY[$j]}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/chr_used_fstplot.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.
      done
    fi
  else
    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --fst CATEGORY --pheno "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list --memory "$MAX_MEM_USAGE" --threads 8 --out "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst
    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst.fst.summary "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_fst.fst.summary
    perl "${PERL_PROGRAM_HOME}"/ps_fst_summary_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_fst.fst.summary "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.fst.summary
  fi

  "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl_b --allow-extra-chr --distance square ibs --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs
  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --make-king square --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king
  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king.king.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_kinship.king.id 
  cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs.mibs "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_distance_ibs.mibs
  cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs.mibs.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_distance_ibs.mibs.id
  cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king.king "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_kinship.king

  if [ ${SAMPLES_NO} -le 400 ]
  then

    if [ ${SAM_ANOTHER_NAME_FLAG} -eq 1 ]
    then
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs.mibs "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs.mibs.id ${GROUPS_NO} 'ibs' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king.king "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king.king.id ${GROUPS_NO} 'king' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.mibs.smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.king.smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.mibs.smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.king.smp.list	
    else
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs.mibs "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs.mibs.id ${GROUPS_NO} 'ibs' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl ${SAM_ANOTHER_NAME_FLAG}
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king.king "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king.king.id ${GROUPS_NO} 'king' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl ${SAM_ANOTHER_NAME_FLAG}
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.mibs.id
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.king.id
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.mibs.id
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.king.id
    fi

    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.mibs
    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.king

    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ld"${LD_THRESHOLD}"_ibs_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.mibs
    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_king_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.king

  fi

  if [ "${IMPUTATION_FLAG}" -eq 1 ]
  then
    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --pca meanimpute --memory "$MAX_MEM_USAGE" --threads 8 --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca.eigenvec "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenvec 
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca.eigenval "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenval
   
    perl "${PERL_PROGRAM_HOME}"/ps_make_normalized_pcs.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca.eigenvec "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca.eigenval "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca_norm_pcs.txt
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_im_pca_norm_pcs.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/normalized_plink_pca.txt

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --make-rel meanimpute square --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm
    
    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel.id 

    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel

    awk '{print $NR}' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel > "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt 
    EIGENVAL_SUM=$(perl -lne '$x += $_; END { print $x; }' < "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt)
    if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt ]
    then
      rm -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt
    fi

    if [ ${SAMPLES_NO} -le 400 ]
    then

      if [ ${SAM_ANOTHER_NAME_FLAG} -eq 1 ]
      then
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.smp.list	
      else
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl ${SAM_ANOTHER_NAME_FLAG}
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.id
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.id
      fi

      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel

    fi

  else

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --pca --memory "$MAX_MEM_USAGE" --threads 8 --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca.eigenvec "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenvec
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca.eigenval "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenval

    perl "${PERL_PROGRAM_HOME}"/ps_make_normalized_pcs.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca.eigenvec "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca.eigenval "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca_norm_pcs.txt
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_pca_norm_pcs.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/normalized_plink_pca.txt

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_ld"${LD_THRESHOLD}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --make-rel square --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel.id

    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel
    
    awk '{print $NR}' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel > "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt 
    EIGENVAL_SUM=$(perl -lne '$x += $_; END { print $x; }' < "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt)
    if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt ]
    then
      rm -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt
    fi

    if [ ${SAMPLES_NO} -le 400 ]
    then

      if [ ${SAM_ANOTHER_NAME_FLAG} -eq 1 ]
      then
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.smp.list	
      else
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl ${SAM_ANOTHER_NAME_FLAG}
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.id
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.id
      fi
 
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_ld"${LD_THRESHOLD}"_grm_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel
    fi

  fi

  if [ ${GROUPS_NO} -gt 5 ]
  then
      FST_PLOT_MESSAGE='gr_no'
  else
    if [ "${CHR_CONTIGS_NO}" -eq 0 ]
    then
      FST_PLOT_MESSAGE='chr_no'
    fi
  fi

  perl "${PERL_PROGRAM_HOME}"/ps_save_parameters.pl "$SNP_ONLY_FLAG" "$GENO_VAL" "$MAF_VAL" "$MIND_VAL" "$IMPUTATION_FLAG" "$LD_PRUNING_FLAG" "$LD_WINDOW_SIZE" "$LD_WINDOW_SIZE_UNITS" "$LD_STEP_SIZE" "$LD_THRESHOLD" $CLUSTERING_FLAG $GROUPS_NO $SAM_ANOTHER_NAME_FLAG "$SAMPLES_NO" "$SNP_NO_ALL" "$SNP_NO_AF" "$SNP_NO" "$EIGENVAL_SUM" "$PLOTLY_IMAGE_FORMAT" $MESSAGE_FLAG $FST_PLOT_MESSAGE "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_parameters_list.txt
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_parameters_list.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/parameters_list.txt
  
  if [ ${MESSAGE_FLAG} -eq 1 ]
  then
    cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/message.txt
  fi

  if [ ${SAMPLES_NO} -le 400 ]
  then

    if [ ${GROUPS_NO} -gt 5 ] || [ "${CHR_CONTIGS_NO}" -eq 0 ]
    then
      cp "${SHINY_PROGRAM_HOME}"/without_fst_plot/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    else
      cp "${SHINY_PROGRAM_HOME}"/with_fst_plot/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    fi

  else
     
    if [ ${GROUPS_NO} -gt 5 ] || [ "${CHR_CONTIGS_NO}" -eq 0 ]
    then
      cp "${SHINY_PROGRAM_HOME}"/without_fst_plot_without_heatmap/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    else
      cp "${SHINY_PROGRAM_HOME}"/with_fst_plot_without_heatmap/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    fi

  fi

else

  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.bim "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.bim
  SAMPLES_NO=$( wc -l <"${INPUT_DIR}/${OUTPUT_PREFIX}_pl_b.fam" )
  SNP_NO=$( grep -vc '^#' "${INPUT_DIR}/${OUTPUT_PREFIX}_pl2_b.pvar" )

  if [ ${CLUSTERING_FLAG} -eq 1 ]
  then
    GROUPS_NO=$CLUSTER_K
    "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b --allow-extra-chr --cluster --K $GROUPS_NO --mds-plot 10 --memory "$MAX_MEM_USAGE" --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl
    perl "${PERL_PROGRAM_HOME}"/ps_make_groups_list.pl ${CLUSTERING_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster2 "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_orig.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list  "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster1 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster1
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster2 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster2
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster3 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster3
  else
    perl "${PERL_PROGRAM_HOME}"/ps_make_groups_list.pl ${CLUSTERING_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${SAMPLES_ID_FOR_ANA}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_orig.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list  "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list
    if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list ]
    then
      GROUPS_NO=$( awk '{print $3}' "${INPUT_DIR}/${OUTPUT_PREFIX}_groups_for_sort.list" | sort | uniq | wc -l )
      "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b --allow-extra-chr --cluster --K "$GROUPS_NO" --mds-plot 10 --memory "$MAX_MEM_USAGE" --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl
    else
      GROUPS_NO=2
      "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b --allow-extra-chr --cluster --K $GROUPS_NO --mds-plot 10 --memory "$MAX_MEM_USAGE" --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl
      CLUSTERING_FLAG=1
      perl "${PERL_PROGRAM_HOME}"/ps_make_groups_list.pl ${CLUSTERING_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.fam "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster2 "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_orig.list "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list  "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list
      cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster1 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster1
      cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster2 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster2
      cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.cluster3 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_cluster.cluster3
      echo "There are no valid groups in the ${SAMPLES_ID_FOR_ANA} file. Cluster analysis (K=2) was performed to group the samples into clusters."
      perl "${PERL_PROGRAM_HOME}"/ps_warning_mess.pl 'samples_groups' "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt
      MESSAGE_FLAG=1
    fi
  fi

  cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl.mds "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_mds_plot.mds
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/groups_names_numbers.list
 
  if [ ${GROUPS_NO} -le 5 ]
  then
    perl "${PERL_PROGRAM_HOME}"/ps_chr_no_count.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b.bim "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/chr_used_fstplot.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/chr_notused_fstplot.txt
    CHR_CONTIGS_NO=$( wc -l <"${SHINY_APP_DIR}/${OUTPUT_PREFIX}/data/chr_used_fstplot.txt" )

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --fst CATEGORY 'report-variants' --pheno "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list --memory "$MAX_MEM_USAGE" --threads 8 --out "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst
    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst.fst.summary "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_fst.fst.summary
    perl "${PERL_PROGRAM_HOME}"/ps_fst_summary_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst.fst.summary "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.fst.summary

    FST_VAR_FILES=`perl ${PERL_PROGRAM_HOME}/ps_fst_var_files.pl ${FST_OUTPUT_DIR}/${OUTPUT_PREFIX}_fst.fst.summary`
    declare -a FST_VAR_FILES_ARRAY=(${FST_VAR_FILES})
    FST_FILES_ARRAY_LEN=$( grep -vc '^#' "${FST_OUTPUT_DIR}/${OUTPUT_PREFIX}_fst.fst.summary" )

    for (( i = 0; i < $FST_FILES_ARRAY_LEN; i++ ))
    do
      perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst."${FST_VAR_FILES_ARRAY[$i]}" "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_fst."${FST_VAR_FILES_ARRAY[$i]}"
    done

    if [ "${CHR_CONTIGS_NO}" -gt 0 ]
    then
      for (( j = 0; j < $FST_FILES_ARRAY_LEN; j++ ))
      do
        perl "${PERL_PROGRAM_HOME}"/ps_fst_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst."${FST_VAR_FILES_ARRAY[$j]}" "${FST_VAR_FILES_ARRAY[$j]}" "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/chr_used_fstplot.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.
      done
    fi
  else
    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --fst CATEGORY --pheno "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups.list --memory "$MAX_MEM_USAGE" --threads 8 --out "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst
    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst.fst.summary "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_fst.fst.summary
    perl "${PERL_PROGRAM_HOME}"/ps_fst_summary_edit.pl "${FST_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_fst.fst.summary "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_names_numbers.list "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.fst.summary
  fi

  "${PLINK_HOME}"/plink --bfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_b --allow-extra-chr --distance square ibs --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs
  "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --make-king square --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king

  perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king.king.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_kinship.king.id 
  cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_distance_ibs.mibs
  cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_distance_ibs.mibs.id
  cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king.king "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_kinship.king

  if [ ${SAMPLES_NO} -le 400 ]
  then

    if [ ${SAM_ANOTHER_NAME_FLAG} -eq 1 ]
    then
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs.id ${GROUPS_NO} 'ibs' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king.king "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king.king.id ${GROUPS_NO} 'king' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.mibs.smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.king.smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.mibs.smp.list	
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.king.smp.list	
    else
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs.mibs.id ${GROUPS_NO} 'ibs' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl ${SAM_ANOTHER_NAME_FLAG}
      perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king.king "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king.king.id ${GROUPS_NO} 'king' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl ${SAM_ANOTHER_NAME_FLAG}
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.mibs.id
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.king.id
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.mibs.id
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.king.id
    fi

    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.mibs
    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.king

    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl_ibs_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.mibs
    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_king_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.king
 
  fi

  if [ "${IMPUTATION_FLAG}" -eq 1 ]
  then

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --pca meanimpute --memory "$MAX_MEM_USAGE" --threads 8 --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca.eigenvec "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenvec
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca.eigenval "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenval

    perl "${PERL_PROGRAM_HOME}"/ps_make_normalized_pcs.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca.eigenvec "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca.eigenval "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca_norm_pcs.txt
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_im_pca_norm_pcs.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/normalized_plink_pca.txt

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --make-rel meanimpute square --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel.id
    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel

    awk '{print $NR}' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel > "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt 
    EIGENVAL_SUM=$(perl -lne '$x += $_; END { print $x; }' < "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt)
    if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt ]
    then
      rm -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt
    fi

    if [ ${SAMPLES_NO} -le 400 ]
    then

      if [ ${SAM_ANOTHER_NAME_FLAG} -eq 1 ]
      then
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.smp.list	
      else
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl ${SAM_ANOTHER_NAME_FLAG}
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.id
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.id
      fi

      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel

    fi

  else

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --pca --memory "$MAX_MEM_USAGE" --threads 8 --out "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca.eigenvec "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenvec
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca.eigenval "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_pca.eigenval

    perl "${PERL_PROGRAM_HOME}"/ps_make_normalized_pcs.pl "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca.eigenvec "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca.eigenval "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca_norm_pcs.txt
    cp "${PSA_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_pca_norm_pcs.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/normalized_plink_pca.txt

    "${PLINK2_HOME}"/plink2 --pfile "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_b --allow-extra-chr --read-freq "${ALLELE_FREQ_COUNTS_FILE}" --make-rel square --memory "$MAX_MEM_USAGE" --threads 8 --out "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm

    perl "${PERL_PROGRAM_HOME}"/ps_columns_names_edit.pl "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel.id 
    cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/plink_grm.rel

    awk '{print $NR}' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel > "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt 
    EIGENVAL_SUM=$(perl -lne '$x += $_; END { print $x; }' < "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt)

    if [ -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt ]
    then
      rm -f "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_grm_diagonal.txt
    fi

    if [ ${SAMPLES_NO} -le 400 ]
    then

      if [ ${SAM_ANOTHER_NAME_FLAG} -eq 1 ]
      then
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl ${SAM_ANOTHER_NAME_FLAG} "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl_smp.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.smp.list	
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl_smp_os.list	 "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.smp.list	
      else
        perl "${PERL_PROGRAM_HOME}"/ps_matrix_edit.pl "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_groups_for_sort.list "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm.rel.id ${GROUPS_NO} 'rel' "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl ${SAM_ANOTHER_NAME_FLAG}
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel.id
        cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl.orig_sorted.id "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel.id
      fi

      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/results_data.rel
      cp "${KSH_OUTPUT_DIR}"/"${OUTPUT_PREFIX}"_pl2_grm_pl.orig_sorted "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/os_results_data.rel

    fi

  fi

  if [ ${GROUPS_NO} -gt 5 ]
  then
      FST_PLOT_MESSAGE='gr_no'
  else
    if [ "${CHR_CONTIGS_NO}" -eq 0 ]
    then
      FST_PLOT_MESSAGE='chr_no'
    fi
  fi

  perl "${PERL_PROGRAM_HOME}"/ps_save_parameters.pl "$SNP_ONLY_FLAG" "$GENO_VAL" "$MAF_VAL" "$MIND_VAL" "$IMPUTATION_FLAG" "$LD_PRUNING_FLAG" "$LD_WINDOW_SIZE" "$LD_WINDOW_SIZE_UNITS" "$LD_STEP_SIZE" "$LD_THRESHOLD" $CLUSTERING_FLAG $GROUPS_NO $SAM_ANOTHER_NAME_FLAG "$SAMPLES_NO" "$SNP_NO_ALL" "$SNP_NO_AF" "$SNP_NO" "$EIGENVAL_SUM" "$PLOTLY_IMAGE_FORMAT" $MESSAGE_FLAG $FST_PLOT_MESSAGE "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_parameters_list.txt
  cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_parameters_list.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/parameters_list.txt

  if [ ${MESSAGE_FLAG} -eq 1 ]
  then
    cp "${INPUT_DIR}"/"${OUTPUT_PREFIX}"_message.txt "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/data/message.txt
  fi

  if [ ${SAMPLES_NO} -le 400 ]
  then

    if [ ${GROUPS_NO} -gt 5 ] || [ "${CHR_CONTIGS_NO}" -eq 0 ]
    then
      cp "${SHINY_PROGRAM_HOME}"/without_fst_plot/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    else
      cp "${SHINY_PROGRAM_HOME}"/with_fst_plot/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    fi

  else

    if [ ${GROUPS_NO} -gt 5 ] || [ "${CHR_CONTIGS_NO}" -eq 0 ]
    then
      cp "${SHINY_PROGRAM_HOME}"/without_fst_plot_without_heatmap/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    else
      cp "${SHINY_PROGRAM_HOME}"/with_fst_plot_without_heatmap/app.R "${SHINY_APP_DIR}"/"${OUTPUT_PREFIX}"/
    fi

  fi

fi

cd "${SHINY_APP_DIR}"
zip -rm "${OUTPUT_PREFIX}" "${OUTPUT_PREFIX}"

TIME_END=`date +%s`
echo "End time: `date '+%Y/%m/%d %H:%M:%S'` End the analysis stage"

TIME_EXEC=`expr ${TIME_END} - ${TIME_START}`
echo "Execution time is $TIME_EXEC seconds"
