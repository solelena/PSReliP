# PSReliP
***Population Structure and Relatedness integrated Pipeline*** <br>
The integrated pipeline for analysis and visualization of population structure and relatedness based on genome-wide genetic variant data<br>
## Features
- Quality control and filtering of samples and variants.
- Calculation of basic sample statistics, such as the types of observed variants, inbreeding coefficients and some others, performed before and after data filtering.
- Analysis of population stratification using PCA and MDS, and if it is selected, complete-linkage hierarchical clustering of samples based on IBS distance matrix.
- Calculation of Wright's fixation index (FST).
- Calculation of IBS distance matrix and analysis of genetic relatedness by estimating KING kinship coefficient matrix and genomic relationship matrix (GRM).
- Interactive visualizations of analysis results using R Shiny technology.
- Ability for users to download analysis results and all plotted graphs using the web interface.
#### The structure and main features of the PSReliP pipeline
<img src="./Images/overview_pipeline_structure.png" width=80% height=80%>

## Implementation
- Analysis stage

  The analysis stage, which includes a pre-analysis step, is performed by the two bash shell scripts that contain PLINK, bash, and Unix commands and invoke in-house [PERL programs](./Analysis/perl_programs). These bash shell scripts are executed from the command line on UNIX or LINUX operating systems and take several arguments from a [configuration file](./Analysis/psrelip.config). This configuration file must be edited by the user and contain information about the pipeline installation directory, the working directory, input files, and parameter values used in the analysis and visualization processes.<br>
  PLINK (1.9 and 2.0) is the main software used in all analysis steps in this pipeline. We use PLINK 2.0 in all cases if it implements the required commands. For commands like --ibc, --cluster, --mds-plot, and --distance that are not yet implemented in PLINK 2.0, we use the version 1.9 of the PLINK software.<br>
  The first pre-analysis step of PSRelIP is to convert variant call format (VCF) or binary variant call format (BCF) files into PLINK format files. This step is performed by running the [first shell script](./Analysis/shell_scripts/pre_analysis_first_script.sh) that takes as input VCF (possibly gzipped) and BCF files, which can be either uncompressed or BGZF-compressed (supported by htslib).The main outputs of this step are PLINK 2 binary files in the following formats: PGEN, binary genotype file format; PSAM, the format in which sample information is stored; and PVAR, the format in which non-genotype variant information is stored. This newly created PLINK 2 binary fileset is used as input for the following analysis steps. Only one filter, such as ‘--max-alleles 2’, is applied in this pre-analysis processing step.<br>
  It is enough to run the first shell script only once for a given set of genetic variants for one specified working directory to prepare the input files for the following analysis. If you change the working directory, you need to start the the analysis stage from the beginning and run the first shell script again.<br>
  The analysis stage itself is performed by running the [second shell script](./Analysis/shell_scripts/analysis_second_script.sh), which executes all steps of the analysis carried out by this pipeline. During the analysis stage, the following processes are performed:
  1. quality control and filtering of samples and variants
  2. calculation of basic sample statistics
  3. analysis of population stratification using PCA, MDS and clustering
  4. calculation of Wright's FST
  5. calculation of IBS matrix, GRM and KING kinship coefficient matrix<br>

  All these analysis processes are carried out by PLINK 1.9 and 2.0 software.<br>
  While running this second shell script, the PLINK, bash, and Unix commands are executed sequentially, and many of these commands take input from the previous command and produce output for the next one. Many of the parameters used in the analysis steps can be varied by the user by appropriately changing their values in the [configuration file](./Analysis/psrelip.config) before running the shell script. Users can run the second shell script multiple times on the given genetic variant dataset and, using different parameter values, perform the analysis that best matches their data.
- Visualization component

  To visualize the results of the analysis, we created a web visualization component for PSRelIP by developing the Shiny app, an interactive R-based web application using [R Shiny technology](https://github.com/rstudio/shiny).<br>
  We use the Shiny package in combination with the [Plotly's R graphing library](https://github.com/plotly/plotly.R), which allows the creation of interactive graphs and provides basic interactivity such as zooming in and out, panning graphs, point value display, and much more. Using the Plotly R library for basic charts, we created grouped and stacked bar charts and line plots and a combination of these for basic sample statistics, including GCTA inbreeding coefficient report, and scatter plot for the PS analysis results (PCA plot). In the scatter plot for PCA (bubble chart), marker sizes are variable and marker colors are mapped to a categorical variable.<br>
  Using Plotly in conjunction with the [‘manhattanly’ R package](https://github.com/sahirbhatnagar/manhattanly/), we created Manhattan plots for the Wright's fixation index (FST) analysis results. In these plots, the genetic variants are plotted with per-variant FST values against their genomic position. Manhattan plots implemented with the ‘manhattanly’ package have the advantage of including extra annotation information to each point of these plots.<br>
  Using Plotly in conjunction with the [‘heatmaply’ R package](https://github.com/talgalili/heatmaply/), we created heatmaps of IBS distances, genetic relationships, and kinship coefficients across all individuals (samples). Interactive heatmaps have the capability of zooming into a region of interest and allow the checking of values by hovering the mouse over a cell.<br>
  To visualize the basic statistics of the samples, along with the charts, we also created tables with the [‘DT’ (DataTables) R package](https://github.com/rstudio/DT/), which allows users to display their data as tables in the HTML pages and provides filtering, sorting, searching, and other features in the tables.<br>


#### Implementation of the PSReIP pipeline
<img src="https://github.com/solelena/PSReliP/blob/main/Images/pipeline_implementation.png" width=90% height=90%>

## Installation
- Install PLINK (1.9 and 2.0) and the necessary R libraries in UNIX/Linux based OS.
- Create a directory in your home directory you would like to install the PSReliP pipeline.
- Copy the pipeline directory containing the shell scripts, configuration file, Perl programs, and Shiny app.R files to the directory you created.

## Getting Started

