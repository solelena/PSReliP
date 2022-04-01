#! /bin/bash
#

#source $1
source /lustre/home/elena/PSReliP/rapdb_5gr.config 

echo "PLINK2_DEV_HOME=$PLINK2_DEV_HOME" >&2

echo "TOOL_INSTALL_DIR=$TOOL_INSTALL_DIR" >&2
PERL_PROGRAM_HOME=${TOOL_INSTALL_DIR}/program_files/perl_programs

echo "VCF_FILE_NAME=$VCF_FILE_NAME" >&2

echo "WD=$WD" >&2
BED_INPUT_FILE=${WD}/bed_files/plink_input_data

echo "MAX_MEM_USAGE=$MAX_MEM_USAGE" >&2

if [ -d "${WD}"/bed_files/ ]
then
  echo "Output directory 'bed_files' already exists."
  rm -f "${WD}"/bed_files/*
else
  mkdir -p "${WD}"/bed_files
fi

if [ "${VCF_FILE_NAME##*.}" = "bcf" ]
then
  "${PLINK2_DEV_HOME}"/plink2 --bcf "${VCF_FILE_NAME}" --allow-extra-chr --max-alleles 2 --make-pgen --memory "$MAX_MEM_USAGE" --out "${BED_INPUT_FILE}"_temp
elif [[ $VCF_FILE_NAME =~ \bcf.gz$ ]]
then
  "${PLINK2_DEV_HOME}"/plink2 --bcf "${VCF_FILE_NAME}" --allow-extra-chr --max-alleles 2 --make-pgen --memory "$MAX_MEM_USAGE" --out "${BED_INPUT_FILE}"_temp
elif [ "${VCF_FILE_NAME##*.}" = "vcf" ]
then
  "${PLINK2_DEV_HOME}"/plink2 --vcf "${VCF_FILE_NAME}" --allow-extra-chr --max-alleles 2 --make-pgen --memory "$MAX_MEM_USAGE" --out "${BED_INPUT_FILE}"_temp
elif [[ $VCF_FILE_NAME =~ \vcf.gz$ ]]
then
  "${PLINK2_DEV_HOME}"/plink2 --vcf "${VCF_FILE_NAME}" --allow-extra-chr --max-alleles 2 --make-pgen --memory "$MAX_MEM_USAGE" --out "${BED_INPUT_FILE}"_temp
else
    echo "Please specify the valid VCF file in configuration file."
fi

perl "${PERL_PROGRAM_HOME}"/ps_pl2_pvar_edit.pl "${BED_INPUT_FILE}"_temp.pvar "${BED_INPUT_FILE}".pvar
mv "${BED_INPUT_FILE}"_temp.pgen "${BED_INPUT_FILE}".pgen
mv "${BED_INPUT_FILE}"_temp.psam "${BED_INPUT_FILE}".psam

rm -f "${BED_INPUT_FILE}"_temp.pvar

"${PLINK2_DEV_HOME}"/plink2 --pfile "${BED_INPUT_FILE}" --allow-extra-chr --freq counts --memory "$MAX_MEM_USAGE" --out "${BED_INPUT_FILE}"_frc