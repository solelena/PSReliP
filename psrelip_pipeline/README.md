## PSReliP pipeline
**PSReliP pipeline folder containing all necessary files for executing the pipeline**<br>
  The PSReliP pipeline folder contains the shell scripts (pre_analysis_first_script.sh, analysis_second_script.sh), the pipeline configuration file (psrelip.config), as well as Perl programs and Shiny app.R files inside the program_files folder.
### The pipeline configuration file
#### List of parameters used in the PSReliP pipeline
| Parameters | Parameters description | Details | Possible values of parameters | Default values in the pipeline | Required/Optional/Ignored |
| --- | --- | --- | --- | --- | --- |
| PLINK_HOME | Path to the PLINK executable files | Specify the full path to the executable of PLINK 1.9 (19 Oct 2020 or later<sup>a</sup>). | not empty string | there is no default value | required |
| PLINK2_HOME | Path to the PLINK executable files | Specify the full path to the executable of the development version of PLINK 1.9 (Development (8 Jun 2021) or later<sup>a</sup>). | not empty string | there is no default value | required |
| TOOL_INSTALL_DIR | Installation Directory | Specify the path to the directory where you installed the tool. | not empty string | there is no default value | required |
| WD | Working Directory | Specify the path to the directory where the analysis results and log files will be saved. | not empty string | there is no default value | required |
| VCF_FILE_NAME | Path to the genotype input file | Specify the path to the genotype input file in '.vcf/.vcf.gz/.bcf/.bcf.gz' formats. | not empty string | there is no default value | required |
| SAMPLES_ID_FOR_ANA | Path to the file that lists the samples | Specify the path to the file with the list of IDs, names, and groups of samples that you want to include in the analysis. | string | empty string by default | optional; ignored if $SAM_SELECT_FLAG is equal to 0 and $SAM_ANOTHER_NAME_FLAG is equal to 0 and $CLUSTERING_FLAG is equal to 1 |
| SHINY_APP_DIR | Path to the output directory for the Shiny application | Specify the path to the directory where the Shiny application will be saved. | not empty string | there is no default value | required |
| EXTRA_CHR_FLAG | Flag to allow unrecognized chromosome codes (PLINK's --allow-extra-chr flag) | The flag that allows the user to refer to extra chromosome codes by name. | integer 0 or 1 (--allow-extra-chr flag is used) | default value: 1 | required |
| NUMBER_OF_CHROMOSOMES | Number of chromosomes | Specify the number of chromosomes that you want included in the analysis. | non negative integer | default value: 0 | optional if $EXTRA_CHR_FLAG is equal to 0; ignored if $EXTRA_CHR_FLAG is equal to 1 |
| SNP_ONLY_FLAG | Keep only SNPs (PLINK's --snps-only flag) | --snps-only' excludes all variants with one or more multi-character allele codes.<sup>b</sup> | integer 0 or 1 (--snps-only flag is used) | default value: 0 | required |
| GENO_VAL | Missing genotype rates (PLINK's --geno [maximum per-variant]) | --geno' filters out all variants with missing call rates exceeding the provided value (default 0.1) to be removed.<sup>b</sup> | decimal numbers from 0 to 1 (in PLINK 2.0 the default is 0.1) | default value: 0.2 | required |
| MIND_VAL | Missing genotype rates (PLINK's --geno [maximum per-sample]) | Exclude samples (--mind) with missing call frequencies greater than a threshold (default 0.1)<sup>c</sup> | decimal numbers from 0 to 1 (in PLINK 2.0 the default is 0.1) | default value: 0.2 | required |
| MAF_VAL | Allele frequencies | --maf' filters out all variants with allele frequency below the provided threshold (default 0.01).<sup>b<sup/> | decimal numbers from 0 to 1 (in PLINK 2.0 the default is 0.01) | default value: 0.05 | required |
| IMPUTATION_FLAG | Mean-imputes missing genotype calls (for PLINK's --pca and --make-rel flags) | Use the 'meanimpute' modifier to request mean-imputes for missing genotype calls for the standard computation.<sup>b</sup> | integer 0 (--pca; --make-rel) or 1 (--pca meanimpute; --make-rel meanimpute) | default value: 1 | required |
| LD_PRUNING_FLAG | Linkage disequilibrium (variant pruning) | --indep-pairwise' command produces a pruned subset of variants that are in approximate linkage equilibrium with each other.<sup>b</sup> | integer 0 or 1 (--indep-pairwise flag is used) | default value: 1 | required|
| LD_WINDOW_SIZE | Linkage disequilibrium (window size) | Window size in variant count or kilobase (if the 'kb' modifier is present) units.<sup>b</sup> | non negative integer | default value: 100 | required if $LD_PRUNING_FLAG is equal to 1; ignored if $LD_PRUNING_FLAG is equal to 0 |
| LD_WINDOW_SIZE_UNITS | Linkage disequilibrium (window size units) | Window size units: vriant count ('vc') or kilobase ('kb') units.<sup> | string: "vc" (variant count) or"kb" (kilobase) | default value: "vc" | required if $LD_PRUNING_FLAG is equal to 1; ignored if $LD_PRUNING_FLAG is equal to 0 |
| LD_STEP_SIZE | Linkage disequilibrium (variant count) | Variant count to shift the window at the end of each step (default 1, and now required to be 1 when a kilobase window is used)<sup>b</sup> | non negative integer | default value: 1 | optional if $LD_PRUNING_FLAG is equal to 1; ignored if $LD_PRUNING_FLAG is equal to 0 |
| LD_THRESHOLD | Linkage disequilibrium (r2 threshold) | Pairs of variants with squared correlation greater than the threshold are pruned from the window until no such pairs remain.<sup>b</sup> | decimal numbers from 0 to 1 | default value: 0.2 | required if $LD_PRUNING_FLAG is equal to 1; ignored if $LD_PRUNING_FLAG is equal to 0 |
| CLUSTERING_FLAG | Hierarchical clustering (PLINK's --cluster flag) | --cluster' uses IBS values to perform complete linkage clustering.<sup>d</sup> | integer 0 (groups provided by user are used) or 1 (hierarchical clustering is used) | default value: 1 | required |
| CLUSTER_K | Hierarchical clustering (clustering constraints) | --cluster --K <minimum final cluster count>' --K stops cluster merging once there are no more than the given number of clusters remaining.<sup>d</sup>| non negative integer | default value: 2 | required if $CLUSTERING_FLAG is equal to 1; ignored if $CLUSTERING_FLAG is equal to 0 |
| SAM_SELECT_FLAG | Sample selection | Set to 0 to use all samples for which data is present in the genotype input file, and set to 1 to use only selected samples. | integer 0 (all samples) or 1 (only selected samples) | default value: 0 | optional |
| SAM_ANOTHER_NAME_FLAG | Setting sample names | Set to 0 to identify the samples by IDs used in the genotype input file, and set to 1 to use the sample names other than sample IDs. | integer 0 (IDs from the genotype input file) or 1 (sample names other than sample IDs) | default value: 0 | optional |
| PLOTLY_IMAGE_FORMAT | Types of image file formats | Set the image file format to export the plot as a static image. | string ( one of the following: png, jpeg, webp, svg, pdf) | default value: "jpeg" | required |
| OUTPUT_PREFIX | Shiny application name | Specify the Shiny app directory name: this name will be part of the URL of the Shiny application. | not empty string | default value: "app_name" | required |
| MAX_MEM_USAGE | System resource usage (PLINK's --memory flag) | Set size, in MB, of initial workspace malloc attempt.<sup>c</sup> 32-bit PLINK limits workspace size to roughly 2 GB.<sup>d</sup> | non negative integer | default value: 2000 | required |
| MAX_THREADS | System resource usage (PLINK's  --threads flag) | Set maximum number of compute threads.<sup>c</sup> (depends on your machine) | non negative integer | default value: 8 | required |

**Note:** <sup>a</sup> represents the version of the PLINK executable used in our pipeline; <sup>b</sup> denotes a quotation from the [PLINK 2.0 User Manual](https://www.cog-genomics.org/plink/2.0/); <sup>c</sup> denotes a quotation from the PLINK 2.0 Command-line help; <sup>d</sup> denotes a quotation from the [PLINK 1.9 User Manual](https://www.cog-genomics.org/plink/1.9/).
### Implementation of the PSReliP pipeline
Note that ($) is used to denote variables with values defined in the configuration file (Supplementary Table 1) and in the corresponding shell script.
In the PSRelIP pipeline, in all PLINK command lines the --memory $MAX_MEM_USAGE and –threads $MAX_THREADS flags are used.
First shell script:
The PLINK command lines to convert VCF/BCF to PLINK format (PLINK 2 binary fileset will be created):
plink2 --vcf $VCF_FILE_NAME --allow-extra-chr --max-alleles 2 --make-pgen --out binary_fileset
plink2 --bcf $VCF_FILE_NAME --allow-extra-chr --max-alleles 2 --make-pgen –out binary_fileset
The PLINK command line to generate an allele count report, which is a valid input for --read-freq:
plink2 --pfile binary_fileset --allow-extra-chr --freq counts --out plink2.acount
In addition to the PLINK commands, in-house Perl program is used to create identifiers for all variants in the binary_fileset.pvar file.
Second shell script:
The PLINK command lines for input filtering:
of samples:
--keep samples.list
--mind $MIND_VAL
of variants:
--chr $RANGE_OF_CHROMOSOMES
--snps-only
--geno $GENO_VAL
--maf $MAF_VAL
The PLINK command lines for basic statistics calculation:
of original dataset and filtered and LD pruned dataset:
--sample-counts
--missing sample-only
of filtered and LD pruned dataset:
--het 'cols=+het,+het'
--ibc
The PLINK command lines for LD-based variant pruning (a pruned subset of variants will be written to plink2.prune.in, which is valid input for --extract):
window size in kilobase:
--indep-pairwise $LD_WINDOW_SIZE $LD_WINDOW_SIZE_UNITS 1 $LD_THRESHOLD
window size in variant count:
--indep-pairwise $LD_WINDOW_SIZE $LD_STEP_SIZE $LD_THRESHOLD
for excluding all unlisted variants from the current analysis:
--extract plink2.prune.in
The PLINK command line for clustering calculations and multidimensional scaling (MDS) report generation (PLINK 1.9):
--cluster --K $GROUPS_NO --mds-plot 10
The PLINK command lines for top 10 principal components (PCs) extraction:
--read-freq plink2.acount --pca
with the 'meanimpute' modifier to request mean-imputes missing genotype calls:
--read-freq plink2.acount --pca meanimpute
The PLINK command lines for FST (Pairwise fixation index) estimation between pairs of subpopulations defined as a categorical phenotype:
--fst CATEGORY --pheno groups.list
with the 'report-variants' modifier to request per-variant FST estimates:
--fst CATEGORY 'report-variants' --pheno groups.list
The PLINK command line for IBS (identity-by-state) matrix calculation (PLINK 1.9):
--distance square ibs
The PLINK command lines for relationship matrix computation:
--read-freq plink2.acount --make-rel square
with the 'meanimpute' modifier to request mean-imputes missing genotype calls:
--read-freq plink2.acount --make-rel meanimpute square
The PLINK command line for KING kinship coefficients computation:
--make-king square
In addition to the PLINK commands, in-house Perl programs are used to reorder samples and their corresponding values in matrices of various types, to edit various values (such as replacing negative values with 0) for visualization purpose, for pipelining, and some other purposes.

  
  
  
  
