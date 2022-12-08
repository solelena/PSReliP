# <ins>P</ins>opulation <ins>S</ins>tructure and <ins>Rel</ins>atedness <ins>i</ins>ntegrated <ins>P</ins>ipeline (PSReliP)
### ***PSReliP: an integrated pipeline for analysis and visualization of Population Structure and Relatedness based on genome-wide genetic variant data***  
  The PSReliP pipeline allows users to quickly analyze genetic variants such as single nucleotide polymorphisms and small insertions or deletions at the genome level to estimate population structure and cryptic relatedness using PLINK software and to visualize the analysis results in interactive tables, plots, and charts using Shiny technology. The analysis and assessment of population stratification and genetic relatedness can aid in choosing an appropriate approach for the statistical analysis of GWAS data and predictions in genomic selection. The various outputs from PLINK can be used for further downstream analysis.<br>
## Features
- QC and  and filtering of samples and variants;
- calculation of basic sample statistics, such as the types of observed variants, inbreeding coefficients, etc., and performing the before and after data filtering;
- analysis of PS using PCA and MDS, and complete-linkage hierarchical clustering of samples based on the IBS distance matrix, if selected;
- calculation of Wright's FST;
- calculation of the IBS distance matrix and analysis of genetic relatedness by estimating the KING kinship coefficient matrix and GRM;
- interactive visualization of the analysis results using Shiny technology;
- ability for users to download analysis results and all plotted graphs using the web interface.
### ***The structure and main features of the PSReliP pipeline***
<img src="./Images/overview_pipeline_structure.png" width=100% height=100%>

## Implementation
- **Analysis stage**  
  The analysis stage, which includes the pre-analysis step, is performed by two bash shell scripts that contained PLINK command lines, Linux commands and invoked in-house [Perl programs](./psrelip_pipeline/program_files/perl_programs). These bash shell scripts are executed from the command line on Linux-based operating systems and take several arguments from the [configuration file](./psrelip_pipeline/psrelip.config). The configuration file is located in the PSReliP installation directory and contains information about the paths to the PLINK executables (1.9 and 2.0), pipeline installation directory, working directory, input files, and parameter values used in the analysis and visualization processes. Users must edit the configuration file before executing the bash shell scripts. The details of the setting parameters are described in the configuration file.<br>
  PLINK (1.9 and 2.0) is the main software used in all the analysis steps in PSReliP. We used PLINK 2.0 in all cases; however, there are certain commands, such as --ibc, --cluster, --mds-plot, and --distance, that have not yet been implemented in PLINK 2.0; in such a case, we used version 1.9 of the PLINK software.<br>
  In the pre-analysis step of PSReliP, the VCF or BCF files areconverted into PLINK format files. This step is performed by running the [first shell script](./psrelip_pipeline/pre_analysis_first_script.sh) that takes VCF (possibly gzipped) and BCF files as inputs, which can be either uncompressed or BGZF-compressed (supported by htslib). The main outputs of this step are PLINK 2 binary files in the following formats: PGEN, binary genotype file format; PSAM, format in which sample information is stored; and PVAR, format in which variant information is stored. The newly created PLINK 2 binary files are used as inputs for the following analysis steps. Only one filter, such as ‘--max-alleles 2’, is applied in this pre-analysis processing step. It is sufficient to run the first shell script only once for a given set of genetic variants for one specified working directory to prepare the input files for the following analysis. When changing the working directory, it is necessary to start the analysis stage from the beginning and run the first shell script again.<br>
  The analysis stage is performed by running the [second shell script](./psrelip_pipeline/analysis_second_script.sh), which executes all the analysis steps carried out by this pipeline. As mentioned above, during the analysis stage, the following processes are performed:
 - QC and filtering of samples and variants;
 - calculation of basic sample statistics;
 - analysis of PS using PCA, MDS, and clustering;
 - calculation of Wright's FST;
 - calculation of the IBS, GRM, and KING kinship coefficient matrices.<br>
  All analyses were carried out using PLINK 1.9 and 2.0 software. While running the second shell script, PLINK and Linux bash commands are executed sequentially, and many of these commands take input from the previous command and produce output for the next command. Users can alter multiple parameters used in the analysis steps by appropriately changing their values in the [configuration file](./psrelip_pipeline/psrelip.config) before running the shell script. Users can run the second shell script multiple times on the given genetic variant dataset using different parameter values and perform the analysis that best matches their data.
- **Visualization component**  
  To visualize the results of the analysis, we created a web-based visualization stage for PSReliP. We implemented this stage using [Shiny technology](https://github.com/rstudio/shiny), which provides a dynamic and interactive UI, and developed the Shiny application, an interactive R-based web application.<br>
  We used the Shiny package in combination with [Plotly's R graphing library](https://github.com/plotly/plotly.R), which allows the creation of interactive graphs and provides basic interactivity, such as zooming in and out, panning graphs, point value display, etc. Using the Plotly R library for basic charts, we created grouped and stacked bar charts and line plots as well as a combination of these for basic sample statistics, including GCTA inbreeding coefficient report and scatter plot for the results of PS analysis (PCA plot). In the scatter plot for PCA (bubble chart), marker sizes are variable and marker colors are mapped to a categorical variable.<br>
  Using Plotly in conjunction with the [‘manhattanly’ R package](https://github.com/sahirbhatnagar/manhattanly/), Manhattan plots for Wright's FST analysis results are created. In Manhattan plots, the genetic variants are plotted with per-variant FST values against their genomic positions. Manhattan plots implemented with the ‘manhattanly’ package have the advantage of adding extra annotation information to each point in these plots.<br>
  Heatmaps of IBS distances, genetic relationships, and kinship coefficients across all individuals (samples) are created using Plotly in conjunction with the [‘heatmaply’ R package](https://github.com/talgalili/heatmaply/). Interactive heatmaps can zoom into a region of interest and allow the checking of values by hovering the mouse over a cell.<br>
  To visualize the basic statistics of the samples, in addition to charts, tables are created with the [‘DT’ (DataTables) R package](https://github.com/rstudio/DT/), which allows users to display their data as tables in the HTML pages and provides filtering, sorting, searching, and other features in the tables.
### ***Implementation of the PSReliP pipeline***
<img src="https://github.com/solelena/PSReliP/blob/main/Images/pipeline_implementation.png" width=100% height=100%>

## Installation of the PSReliP pipeline
- Install PLINK ([1.9](https://www.cog-genomics.org/plink/1.9/) and [2.0](https://www.cog-genomics.org/plink/2.0/)) from binary distributions on Linux-based operating systems. 
  - Download the latest stable version of PLINK 1.9 and the latest version of PLINK 2.0 from the binary downloads section from the official website (select the appropriate operating system in which you want to use it).
  - Unpack the zip file on your computer.
  - Specify the path to the PLINK executables (plink and plink2 executable files) in the "PLINK_HOME" and "PLINK2_HOME" parameters in the [configuration file](./psrelip_pipeline/psrelip.config).
- Create a directory in the home directory where you want to install the PSReliP pipeline.
- Install the PSReliP pipeline.
  - Download the PSReliP pipeline source code [latest release](https://github.com/solelena/PSReliP/releases/download/v1.1.0/v1.1.tar.gz) in the istalation directory. Unzip the [latest release].tar.gz file with 'tar -xvzf'. The **[user-created directory]/psrelip** directory will be the pipeline installation directory.<br>
  - Another way to install the PSReliP pipeline: copy the files and the 'program_files' folder contained in the [PSReliP pipeline](./psrelip_pipeline) folder, which includes the two shell scripts, configuration file, Perl programs and Shiny app.R files into the directory you created. The **[user-created directory]** directory will be the installation directory for the pipeline.<br>

  The installation directory of the pipeline must be specified in the "TOOL_INSTALL_DIR" parameter in the [configuration file](./psrelip_pipeline/psrelip.config). It is important to leave the names and structure of the 'program_files' folder in this directory. The two shell scripts and the configuration file can be renamed and placed in any directory. The path to the configuration file must be specified in both shell scripts.
- Create a working directory.<br>

  The working directory in which the analysis results and log files will be stored must be specified in the "WD" parameter in the [configuration file](./psrelip_pipeline/psrelip.config). It is sufficient to run the first shell script only once for a given set of genetic variants for one specified working directory to prepare the input files for the following analysis. When changing the working directory, it is necessary to start the analysis stage from the beginning and run the first shell script again.
- Edit the configuration file.<br>

  Edit the [configuration file](./psrelip_pipeline/psrelip.config) and specify the path to the PLINK executables (1.9 and 2.0), the pipeline installation directory and the working directory as described above, and specify the path to the input files and set the parameter values used in the analysis and visualisation processes.
## Preparing to run the Shiny app
- Install the required R packages in Linux-based operating systems if you want to run the Shiny application on the [Linux Shiny Server](https://github.com/rstudio/shiny-server), or in [RStudio](https://www.rstudio.com/products/rstudio) if you want to run the Shiny application in the RStudio Desktop. Installing the Shiny package and the Shiny Server on a Linux-based OS normally requires root privileges. RStudio Desktop is a regular desktop application running on Windows, MacOS, or Linux that can be downloaded from the ['Download RStudio Desktop'](https://rstudio.com/products/rstudio/download/) website. Installation of RStudio Desktop is easier if you have root (or administrator privileges), but you can also do it without these privileges.
- Your Shiny app can also be hosted and deployed to a web page using Shinyapps.io, which is RStudio’s hosting service for Shiny apps. Shinyapps.io is an easy-to-use, secure, and scalable service with free and paid options available.
## Version Requirements
- For analysis stage of pipeline:
  - PLINK 1.9: 2 Apr 2022 or later.
  - PLINK 2.0: 24 Oct 2022 or later.
- For visualization component:
  - R and R packages: R (3.6+), shiny (1.4.0.2+), plotly (4.9.2.1+), manhattanly (0.2.0+), heatmaply (1.1.0+), ggplot2 (3.3.0+), DT (0.16+), stringr (1.4.0).
## Getting Started
* In the configuration file, specify the path to the input genotype file in the '.vcf/.vcf.gz/.bcf/.bcf.gz' format in the 'VCF_FILE_NAME' parameter.
* In the configuration file, in the "WD" parameter, specify the path to the working directory in which all analysis output files will be saved (there can be one working directory for each Variant Call Format file).
* To convert VCF/BCF file to PLINK format, specify the path to the edited configuration file in the first shell script ([pre_analysis_first_script.sh](./psrelip_pipeline/pre_analysis_first_script.sh)) and run this shell script. A set of PLINK 2 binary files will be created and saved in the 'bed_files' subdirectory in the working directory. This shell script uses only one filter such as '--max-alleles 2' (excludes variants with more than 2 alleles). In addition, this script runs the PLINK command line to generate an allele count report, which is a valid input for the --read-freq flag to be used in further analysis. This allele count report will be saved in the same 'bed_files' subdirectory.
* To perform the analysis stage, specify the path to the edited configuration file in the second shell script ([analysis_second_script.sh](./psrelip_pipeline/analysis_second_script.sh)) that executes all the analysis steps carried out by this pipeline and run that shell script. The analysis stage is responsible for performing all the filtering and analysis steps and contains an ordered sequence of PLINK commands along with in-house shell scripts and PERL programs that support data pipelining. You can run the second shell script several times on a given genetic variant dataset and, using different parameter values, perform the analysis that best matches your data. The PSReliP implementation, especially the PLINK command lines with flags and parameters, is described in detail in the README.md file in the [psrelip_pipeline](./psrelip_pipeline) folder.
* At the end of the PSRelIP analysis stage, the second shell script creates a subdirectory in the directory specified in the "SHINY_APP_DIR" parameter of the configuration file with the name specified in the "OUTPUT_PREFIX" parameter, and copies our developed Shiny app (app.R) into that directory. The results of the analysis as well as the argument file for the Shiny app are also copied into this directory, namely its 'data' subdirectory.
### ***Structure of directories and files created in the PSRelIP pipeline***
<img src="https://github.com/solelena/PSReliP/blob/main/Images/dir_files_structure.png" width=100% height=100%>

**Note** that some temporarily created files are deleted during the execution of both shell scripts to reduce disk space usage.<br>
## Running the Shiny app
* To run the newly created Shiny app locally, use RStudio to open the app.R file in the Shiny app folder and click on "Run App" in the upper right corner of the source panel. The Shiny app can also be deployed to [ShinyApps.io](https://www.shinyapps.io/) or hosted on the [Shiny Server](https://www.rstudio.com/products/shiny/shiny-server/).
* We created the Shiny app for the Case Study dataset, which we placed in the [Case_study_datasets](./Case_study_datasets) folder to illustrate the capabilities of our pipeline and the features of its user interface. Details of this case study can be found in the [README.md](./Case_study_datasets/README.md) file located in that folder. Screenshots of the user interface of this Shiny app can be found in the [Images](./Images/case_study_UI_screenshots) folder.<br>

  **If all required R packages (see above) are installed in your R environment, run the following lines in interactive R sessions to launch this Shiny app for the Case Study dataset from the GitHub repository. The application files will be stored in a temporary directory and removed when the app exits.**<br>
  > library(shiny)<br>
  > runGitHub("PSReliP", "solelena", subdir = "Case_study_datasets/rapdb_30depth_5gr_ld_pr")<br>

  **To launch this Shiny app for the Case Study dataset and save the downloaded application files, run the following lines in interactive R sessions (destdir: directory to store the downloaded application files).**<br>
  > library(shiny)<br>
  > runGitHub("PSReliP", "solelena", subdir = "Case_study_datasets/rapdb_30depth_5gr_ld_pr", destdir = "C:/Users/User_name/Directory_name")
