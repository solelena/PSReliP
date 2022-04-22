## Case study datasets:
- ### 110 world-wide rice accessions
***Demonstration of how the PSReliP pipeline can be applied to genome-wide genetic variant data of rice varieties.***<br>
  The folder [rapdb_30depth_5gr_ld_pr](./rapdb_30depth_5gr_ld_pr) is the folder of the Shiny app, which was created as a result of PSRelIP pipeline execution.
#### Input data
  The genome-wide genetic variant data for 110 world-wide rice accessions from five groups, such as three japonica variety groups (JP: Oryza sativa Japonica Group, TEJ: Oryza sativa temperate japonica subgroup, TRJ: Oryza sativa tropical japonica subgroup) and two indica variety groups (IND: Oryza sativa Indica Group, AUS: Oryza sativa aus subgroup). These samples are registered in the Rice Annotation Project Database ([RAP-DB](https://rapdb.dna.affrc.go.jp)) and have an average depth of sequencing coverage greater than 30. Accession numbers, sample names, and group abbreviations or all of these samples are listed in the file [rice_acces_name_gr.list](./rice_acces_name_gr.list).
#### Used parameter values
  The parameter sets and parameter values used in this pipeline run are listed in [rapdb_30depth_5gr_ld_pr.config](./rapdb_30depth_5gr_ld_pr.config), which is the PSReliP pipeline configuration file.
#### Folder contents
  The Shiny application folder contains an app.R file and a 'data' subfolder with the analysis results files.
#### Viewing the shiny app
  Download the Shiny app folder. To run the Shiny app locally, use RStudio to open the app.R file in the Shiny app folder and click on "Run App" in the upper right corner of the source panel. The app will open up in a new window.
