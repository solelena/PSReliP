## PSReliP pipeline
**PSReliP pipeline folder containing all necessary files for executing the pipeline**<br>
  The PSReliP pipeline folder contains two bash shell scripts ([pre_analysis_first_script.sh](./pre_analysis_first_script.sh), [analysis_second_script.sh](./analysis_second_script.sh)), the pipeline configuration file [(psrelip.config)](./psrelip.config), as well as [Perl programs](./program_files/perl_programs) and [Shiny app.R](./program_files/shiny_programs) files inside the program_files folder.
- **Two bash shell scripts.** The analysis stage, which includes the pre-analysis step, is performed by two bash shell scripts that contain PLINK command lines, bash and Unix commands and invoke in-house PERL programs. These bash shell scripts are executed from the command line on UNIX or LINUX operating systems and take several arguments from the configuration file.
- **The pipeline configuration file.** The configuration file must be edited by the user and contain information about the path to the PLINK executables (1.9 and 2.0), the pipeline installation directory, the working directory, the input files, and the parameter values used in the analysis and visualization processes (see the table below for details).
- **Perl programs.** The in-house PERL programs are called from both shell scripts to support data pipelining by selecting appropriate data, formatting data, etc. 
- **Shiny app.R files.** At the end of the PSRelIP analysis stage, the second shell script creates a directory with the name specified by the user in the configuration file, and copies into this directory the Shiny application (app.R) that we developed ourselves. The results of the analysis as well as the file containing the arguments for the Shiny app are also copied to this directory, namely to its ‘data’ subdirectory. This Shiny app creates interactive tables, plots and charts of data and displays them through a web browser. We prepared two Shiny apps that differ only in whether or not they plot the Manhattan plot for the FST values for each variant between pairs of subpopulations. The PLINK --fst command with the 'report-variants' modifier calculates the FST scores for each variant, which we also use in our pipeline if the number of groups/clusters is less than or equal to 5 (to control the output size). In addition, we plot the chromosomes/contigens by one or the entire genome region only if the number of variants contained in them is greater than or equal to 100 and less than or equal to 100,000. If both of these conditions are met, the pipeline will copy the Shiny app.R file containing the Manhattan plot to the Shiny app folder, if one or both conditions are not met, the Shiny app.R file without the Manhattan plot will be used.
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

**Note:** <sup>a</sup> represents the version of the PLINK executable file required for our pipeline; <sup>b</sup> denotes a quotation from the [PLINK 2.0 User Manual](https://www.cog-genomics.org/plink/2.0/); <sup>c</sup> denotes a quotation from the PLINK 2.0 Command-line help; <sup>d</sup> denotes a quotation from the [PLINK 1.9 User Manual](https://www.cog-genomics.org/plink/1.9/).
### Implementation of the PSReliP pipeline
**Note** that **($)** denotes variables with values defined in the configuration file [(psrelip.config)](./psrelip.config) (also see the details in the table above) and corresponding shell script.
* In the PSRelIP pipeline, in all PLINK command lines, the --memory $MAX_MEM_USAGE and --threads $MAX_THREADS flags are used:
#### First shell script:
* The PLINK command lines to convert VCF/BCF to PLINK format (PLINK 2 binary fileset will be created):
> plink2 --vcf $VCF_FILE_NAME --allow-extra-chr --max-alleles 2 --make-pgen --out binary_fileset<br>
> plink2 --bcf $VCF_FILE_NAME --allow-extra-chr --max-alleles 2 --make-pgen –out binary_fileset<br>
* The PLINK command line to generate an allele count report, which is a valid input for --read-freq:
> plink2 --pfile binary_fileset --allow-extra-chr --freq counts --out plink2.acount <br>
* In addition to the PLINK commands, an in-house Perl program is used to create identifiers for all the variants in the binary_fileset.pvar file.
#### Second shell script:
* The PLINK command lines for input filtering:
> **of samples:**<br>
> --keep samples.list<br>
> --mind $MIND_VAL<br>
> **of variants:**<br>
> --chr $RANGE_OF_CHROMOSOMES<br>
> --snps-only<br>
> --geno $GENO_VAL<br>
> --maf $MAF_VAL<br>
* The PLINK command lines for basic statistics calculation:
> **of original dataset and filtered and LD pruned dataset:**<br>
> --sample-counts<br>
> --missing sample-only<br>
> **of filtered and LD pruned dataset:**<br>
> --het 'cols=+het,+het'<br>
> --ibc<br>
* The PLINK command lines for LD-based variant pruning (a pruned subset of variants will be written to plink2.prune.in, which is a valid input for --extract):
> **window size in kilobase:**<br>
> --indep-pairwise $LD_WINDOW_SIZE $LD_WINDOW_SIZE_UNITS 1 $LD_THRESHOLD<br>
> **window size in variant count:**<br>
> --indep-pairwise $LD_WINDOW_SIZE $LD_STEP_SIZE $LD_THRESHOLD<br>
> **for excluding all unlisted variants from the current analysis:**<br>
> --extract plink2.prune.in<br>
* The PLINK command line for clustering calculations and multidimensional scaling (MDS) report generation (PLINK 1.9):
> --cluster --K $GROUPS_NO --mds-plot 10<br>
* The PLINK command line for top 10 principal components (PCs) extraction:
> --read-freq plink2.acount --pca<br>
> **with the 'meanimpute' modifier to request mean-imputes missing genotype calls:**<br>
>--read-freq plink2.acount --pca meanimpute
* The PLINK command line for FST (Pairwise fixation index) estimation between pairs of subpopulations is defined as a categorical phenotype:
> --fst CATEGORY --pheno groups.list<br>
> **with the 'report-variants' modifier to request per-variant FST estimates:**<br>
> --fst CATEGORY 'report-variants' --pheno groups.list
* The PLINK command line for the IBS (identity-by-state) matrix calculation (PLINK 1.9):
> --distance square ibs<br>
* The PLINK command line for relationship matrix computation:
> --read-freq plink2.acount --make-rel square<br>
> **with the 'meanimpute' modifier to request mean-imputes missing genotype calls:**<br>
> --read-freq plink2.acount --make-rel meanimpute square
* The PLINK command line for KING kinship coefficients computation:
> --make-king square<br>
* In addition to the PLINK commands, in-house Perl programs are used to reorder samples and their corresponding values in matrices of various types, to edit various values (such as replacing negative values with 0) for visualization purposes, pipelining, and other purposes.
### The parameter values used, the number of samples and variants, and the required time (first shell script) for the [case study dataset](../Case_study_datasets).
  Used parameter values, number of samples and variants, and required time (first shell script)
| Datasets | Computing time: 8 threads<sup>a</sup>; 8000 MB RAM<sup>b</sup> | Computing time: 32 threads<sup>a</sup>; 32000 MB RAM<sup>b</sup>  | Max alleles | Number of samples | Number of loaded variants | Number of filtered variants |
| --- | --- | --- | --- | --- | --- | --- |
| Rice Dataset | 599s | 376s | 2 | 143 | 35,568,995 | 30,904,333 |

**Note:** <sup>a</sup> “By default, multithreaded PLINK functions employ about as many CPU-intensive threads as your system has available logical cores [(--threads)](https://www.cog-genomics.org/plink/2.0/other#threads)”. <sup>b</sup> “When memory is moderately constrained, a reasonable guideline is to reserve 8000 MiB when working with datasets containing up to 50 million variants, and to add another 1000 MiB for every 10 million variants past that [(--memory)](https://www.cog-genomics.org/plink/2.0/other#memory)”. In the PSRelIP pipeline, the -threads and --memory flags are used in all PLINK command lines, and the values of these parameters can be specified in the configuration file [(psrelip.config)](./psrelip.config)
### The parameter values used, the number of samples and variants, and the required time (second shell script) for the [case study dataset](../Case_study_datasets).
| Datasets | Computing time: 8 threads<sup>a</sup>; 8000 MB RAM<sup>b</sup> | Computing time: 32 threads<sup>a</sup>; 32000 MB RAM<sup>b</sup> | Types of variants | Geno<sup>c</sup> | Mind<sup>c</sup> | Maf<sup>c</sup> | Meanimpute<sup>c</sup> | Clustering<sup>c</sup> | Number of groups<sup>c</sup> | window size<sup>d</sup> | vc or kb<sup>d</sup> | step size<sup>d</sup> | r2 threshold<sup>d</sup> | Samples | Loaded variants | Filtered variants | Filtered and pruned variants |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Rice Dataset | 94s | 81s | SNPs and InDels | 0.2 | 0.2 | 0.05 |	⃝ | × | 5 | 100 | kb | 1 | 0.2 | 110 | 30,904,333 | 4,449,631 | 33,539 |

**Note:** <sup>a</sup> and <sup>b</sup> in the column headings are the same notes as in the table above; <sup>c</sup> setting parameters; <sup>d</sup> setting parameters (LD-based pruning).
  
  
