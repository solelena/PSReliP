## Case study datasets:

[rapdb_30depth_5gr_ld_pr](./rapdb_30depth_5gr_ld_pr) folder is tha 
#### Input data
  The genome-wide genetic variant data for 110 world-wide rice accessions from five groups, such as three japonica variety groups (JP: Oryza sativa Japonica Group, TEJ: Oryza sativa temperate japonica subgroup, TRJ: Oryza sativa tropical japonica subgroup) and two indica variety groups (IND: Oryza sativa Indica Group, AUS: Oryza sativa aus subgroup). These samples are registered in the Rice Annotation Project Database ([RAP-DB](https://rapdb.dna.affrc.go.jp)) and have an average depth of sequencing coverage greater than 30. Accession numbers, sample names, and group abbreviations are listed in the file [rice_acces_name_gr.list](./rice_acces_name_gr.list).

#### Used parameter values
  The parameter sets and parameter values used in this pipeline run are listed in [rapdb_30depth_5gr_ld_pr.config](./rapdb_30depth_5gr_ld_pr.config), which is the PSReliP pipeline configuration file.

in the data folder inside the Shiny app folder.

 Download the Shiny app folder. In RStudio, open app.R file, and click on "Run App" in the upper right corner of the source panel. The app will open up in a new window.
 
 
 The shiny app contains seven tabs (highlighted in blue box), with the opening page showing the first tab "CellInfo vs GeneExpr" (see below), plotting both cell information and gene expression side-by-side on reduced dimensions e.g. UMAP. Users can click on the toggle on the bottom left corner to display the cell numbers in each cluster / group and the number of cells expressing a gene. The next two tabs are similar, showing either two cell information side-by-side (second tab: "CellInfo vs CellInfo") or two gene expressions side-by-side (third tab: "GeneExpr vs GeneExpr").
