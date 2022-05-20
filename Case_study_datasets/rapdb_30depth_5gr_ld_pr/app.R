library(shiny)
library(plotly)
library(manhattanly)
library(heatmaply)
library(ggplot2)
library(DT)
library(stringr)

# Parameters selected by user
u_parameters <- read.table(file = "data/parameters_list.txt", header = FALSE)
message_txt <- c()
if (u_parameters[1,20] == 1) {
  message_txt <- readLines("data/message.txt")
}

smp_fn_orig <- ""
smp_fn <- ""
if (u_parameters[1,13] == 1) {
  smp_fn_orig <- "data/smp_orig.list"
  smp_fn <- "data/smp.list"
} else if (u_parameters[1,13] == 0) {
  smp_fn_orig <- "data/plink_samples_info_orig.fam"
  smp_fn <- "data/plink_samples_info.fam"
}
smp_orig <- read.table(file = smp_fn_orig, header = FALSE)
smps_orig_number <- nrow(smp_orig)
smp <- read.table(file = smp_fn, header = FALSE)
smps_number <- nrow(smp)

clusters <- read.table(file = "data/groups_orig.list", header = TRUE)

# Files for Basic statistics
sample_counts_matrix <- as.matrix(read.table(file = "data/plink_sample_counts.scount", header = TRUE))
missing_data_matrix <- as.matrix(read.table(file = "data/plink_missing.smiss", header = TRUE))
sample_counts_af_matrix <- as.matrix(read.table(file = "data/plink_sample_counts_af.scount", header = TRUE))
missing_data_af_matrix <- as.matrix(read.table(file = "data/plink_missing_af.smiss", header = TRUE))
het_matrix <- matrix(, nrow = smps_number, ncol = 7)
ibc_matrix <- matrix(, nrow = smps_number, ncol = 6)
reports_list <- c("Sample variant-count report", "Sample-based missing data report")
if (u_parameters[1,6] == "yes") {
  het_matrix <- as.matrix(read.table(file = "data/plink_het.het", header = TRUE))
  ibc_matrix <- as.matrix(read.table(file = "data/plink_ibc.ibc", header = TRUE))
  reports_list <- c(reports_list, "Method-of-moments F coefficient estimates")
  reports_list <- c(reports_list, "GCTA inbreeding coefficient report")
}

# Files for Population Stratification analysis
pca_data_matrix <- as.matrix(read.table(file = "data/plink_pca.eigenvec", header = TRUE))
pcs_norm_data_matrix <- as.matrix(read.table(file = "data/normalized_plink_pca.txt", header = TRUE))
mds_data_matrix <- as.matrix(read.table(file = "data/plink_mds_plot.mds", header = TRUE))

pca_eigenvalues <- read.table(file = "data/plink_pca.eigenval", header = FALSE)

unique_groups <- c()
gr_list_orig <- c(as.character(clusters[,2]))
gr_list <- sort(gr_list_orig)
unique_groups <- dplyr::distinct(as.data.frame(gr_list))


# Files for FST estimation
fst_vals <- read.table(file = "data/results_data.fst.summary", header = FALSE)
fst_contigs_data <- read.table(file = "data/chr_used_fstplot.txt", header = FALSE)
fst_contigs_list <- c()
if (length(as.vector(as.character(fst_contigs_data[,1]))) > 1 && length(as.vector(as.character(fst_contigs_data[,1]))) <= 50  && sum(as.vector(as.numeric(fst_contigs_data[,2]))) <= 100000) {
  fst_contigs_list <- c("ALL", as.character(fst_contigs_data[,1]))
} else {
  fst_contigs_list <- c(as.character(fst_contigs_data[,1]))
}

# Files for Kinship
ibs_matrix <- as.matrix(read.table(file = "data/results_data.mibs", header = FALSE))
ibs_matrix_os <- as.matrix(read.table(file = "data/os_results_data.mibs", header = FALSE))
rel_matrix <- as.matrix(read.table(file = "data/results_data.rel", header = FALSE))
rel_matrix_os <- as.matrix(read.table(file = "data/os_results_data.rel", header = FALSE))
king_matrix <- as.matrix(read.table(file = "data/results_data.king", header = FALSE))
king_matrix_os <- as.matrix(read.table(file = "data/os_results_data.king", header = FALSE))

smp_ibs_fn <- ""
smp_ibs_os_fn <- ""
smp_rel_fn <- ""
smp_rel_os_fn <- ""
smp_king_fn <- ""
smp_king_os_fn <- ""

if (u_parameters[1,13] == 1) {
  smp_ibs_fn <- "data/results_data.mibs.smp.list"
  smp_ibs_os_fn <- "data/os_results_data.mibs.smp.list"
  smp_rel_fn <- "data/results_data.rel.smp.list"
  smp_rel_os_fn <- "data/os_results_data.rel.smp.list"
  smp_king_fn <- "data/results_data.king.smp.list"
  smp_king_os_fn <- "data/os_results_data.king.smp.list"
} else if (u_parameters[1,13] == 0) {
  smp_ibs_fn <- "data/results_data.mibs.id"
  smp_ibs_os_fn <- "data/os_results_data.mibs.id"
  smp_rel_fn <- "data/results_data.rel.id"
  smp_rel_os_fn <- "data/os_results_data.rel.id"
  smp_king_fn <- "data/results_data.king.id"
  smp_king_os_fn <- "data/os_results_data.king.id"
}
 
smp_ibs <- read.table(file = smp_ibs_fn, header = TRUE)
smp_ibs_os <- read.table(file = smp_ibs_os_fn, header = TRUE)
smp_rel <- read.table(file = smp_rel_fn, header = TRUE)
smp_rel_os <- read.table(file = smp_rel_os_fn, header = TRUE)
smp_king <- read.table(file = smp_king_fn, header = TRUE)
smp_king_os <- read.table(file = smp_king_os_fn, header = TRUE)

rownames(ibs_matrix) <- smp_ibs[,2]
colnames(ibs_matrix) <- smp_ibs[,2]
rownames(rel_matrix) <- smp_rel[,2]
colnames(rel_matrix) <- smp_rel[,2]
rownames(king_matrix) <- smp_king[,2]
colnames(king_matrix) <- smp_king[,2]

rownames(ibs_matrix_os) <- smp_ibs_os[,2]
colnames(ibs_matrix_os) <- smp_ibs_os[,2]
rownames(rel_matrix_os) <- smp_rel_os[,2]
colnames(rel_matrix_os) <- smp_rel_os[,2]
rownames(king_matrix_os) <- smp_king_os[,2]
colnames(king_matrix_os) <- smp_king_os[,2]

variants_types <- ""
if (u_parameters[1,1] == 1) {
  variants_types <- "SNPs"
} else if (u_parameters[1,1] == 0) {
  variants_types <- "SNPs and InDels"
}

imputation_param <- ""
psa_tools <- ""
grm_tool <- ""
if (u_parameters[1,5] == "yes") {
  imputation_param <- "Imputation of missing genotypes ('meanimpute'): "
  psa_tools <- "meanimpute )"
  grm_tool <- "meanimpute )"
} else if (u_parameters[1,5] == "no") {
  imputation_param <- "Imputation of missing genotypes: "
  psa_tools <- ")"
  grm_tool <- ")"
}

pruning_param <- ""
ld_threshold <- ""
ld_threshold_val <- ""
remaining_var_lab <- ""
remaining_var_val <- ""
if (u_parameters[1,6] == "yes") {
  if (u_parameters[1,8] == "kb") {
   pruning_param <- sprintf("LD-based pruning (--indep-pairwise %s kb %s %s): ", u_parameters[1,7], u_parameters[1,9], u_parameters[1,10])
  } else {
   pruning_param <- sprintf("LD-based pruning (--indep-pairwise %s %s %s): ", u_parameters[1,7], u_parameters[1,9], u_parameters[1,10])
  }
  ld_threshold <- "r2 threshold: "
  ld_threshold_val <- u_parameters[1,10]
  remaining_var_lab <- "Variants after filtering and LD pruning: "
  remaining_var_val <- u_parameters[1,17]
} else if (u_parameters[1,6] == "no") {
  pruning_param <- "LD-based pruning: "
  ld_threshold <- ""
  ld_threshold_val <- ""
}

grp_number <- ""
cluster_com <- ""
cls_pairs_lab <- ""
if (u_parameters[1,11] == "yes") {
  grp_number <- "Minimum final cluster count: "
  cluster_com <- "--cluster uses IBS (Identity-by-state/Hamming distance) values to perform complete linkage clustering. Clusters are colored by different colors."
  cls_pairs_lab <- "Pairs of clusters:"
} else if (u_parameters[1,11] == "no") {
  grp_number <- "Number of groups of samples: "
  cluster_com <- "Linkage clustering was not used because the CLUSTERING FLAG was set to '0'. The groups provided by the user are colored by different colors."
  cls_pairs_lab <- "Pairs of groups:"
}

groups_pairs <- c()
for (i in seq(1, nrow(fst_vals), by = 1)) {
  new_pair <- sprintf("%s-%s", fst_vals[i,1], fst_vals[i,2])
  groups_pairs <- c(groups_pairs, new_pair)
}

psa_pl_col <- c()
if (as.numeric(u_parameters[1,12]) == 2) {
  psa_pl_col <- c("#32CD32","#FF8C00")
} else if (as.numeric(u_parameters[1,12]) == 3) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513")
} else if (as.numeric(u_parameters[1,12]) == 4) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF")
} else if (as.numeric(u_parameters[1,12]) == 5) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B")
} else if (as.numeric(u_parameters[1,12]) == 6) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50")
} else if (as.numeric(u_parameters[1,12]) == 7) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400")
} else if (as.numeric(u_parameters[1,12]) == 8) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700")
} else if (as.numeric(u_parameters[1,12]) == 9) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4")
} else if (as.numeric(u_parameters[1,12]) == 10) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090")
} else if (as.numeric(u_parameters[1,12]) == 11) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB")
} else if (as.numeric(u_parameters[1,12]) == 12) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD")
} else if (as.numeric(u_parameters[1,12]) == 13) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B")
} else if (as.numeric(u_parameters[1,12]) == 14) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C")
} else if (as.numeric(u_parameters[1,12]) == 15) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C","#00BFFF")
} else if (as.numeric(u_parameters[1,12]) == 16) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C","#00BFFF","#BC8F8F")
} else if (as.numeric(u_parameters[1,12]) == 17) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C","#00BFFF","#BC8F8F","#7B68EE")
} else if (as.numeric(u_parameters[1,12]) == 18) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C","#00BFFF","#BC8F8F","#7B68EE","#008080")
} else if (as.numeric(u_parameters[1,12]) == 19) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C","#00BFFF","#BC8F8F","#7B68EE","#008080", "#C71585")
} else if (as.numeric(u_parameters[1,12]) >= 20) {
  psa_pl_col <- c("#32CD32","#FF8C00","#8B4513","#1E90FF","#8B008B","#FF4F50","#006400","#FFD700","#FF69B4","#708090","#008BBB","#0000CD","#B8860B","#DC143C","#00BFFF","#BC8F8F","#7B68EE","#008080", "#C71585", "#BDB76B")
}

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      #all_param {
        border: 1px solid #0000CD;
        color: #0000CD;
        width: 750px;
      }
      #param_title {
        color: #C71585;
        font-weight: bold;
      }
      #param_val {
        color: #008080;
        font-weight: bold;
      }
      h5 {
        color: #C71585;
        font-weight: bold;
      }
      #fst_val {
        color: #0000CD;
        display:inline-block;
      }
      #comment_text {
        color: #0000CD;
      }
      #comment2_text {
        color: #3CB371;
        font-weight: bold;
      }
    "))
   ),
  h3("Population Structure and Relatedness"),
  fluidRow(id = "all_param",
    column(12,
      span(id = "param_title", "Selected parameters:"),
      fluidRow(
        column(6,
          span("Types of variants: "),
          span(id = "param_val", variants_types)
        ),
        column(6,
          span("Hierarchical clustering: "),
          span(id = "param_val", u_parameters[1,11])
        )
      ),
      fluidRow(
        column(6,
          span("Missing genotype rates (--geno): "),
          span(id = "param_val", u_parameters[1,2]),
          span(" (--mind): "),
          span(id = "param_val", u_parameters[1,4])
        ),
        column(6,
          span(grp_number),
          span(id = "param_val", u_parameters[1,12])
        )
      ),
      fluidRow(
        column(6,
          span("Minimum allele frequency (--maf): "),
          span(id = "param_val", u_parameters[1,3])
        ),
        column(6,
          span(pruning_param),
          span(id = "param_val", u_parameters[1,6])
        )
      ),
      fluidRow(
        column(6,
          span(imputation_param),
          span(id = "param_val", u_parameters[1,5])
        ),
        column(6,
          span(ld_threshold),
          span(id = "param_val", ld_threshold_val)
        )
      ),
      span(id = "param_title", "Input filtering performed by PLINK 2.0"),
      fluidRow(
        column(6,
          span("Number of analyzed samples: "),
          span(id = "param_val", u_parameters[1,14])
        ),
        column(6,
          span("Number of loaded variants: "),
          span(id = "param_val", u_parameters[1,15])
        )
      ),
      fluidRow(
        column(6,
          span("Variants remaining after filtering: "),
          span(id = "param_val", u_parameters[1,16])
        ),
        column(6,
          span(remaining_var_lab),
          span(id = "param_val", remaining_var_val)
        )
      )
    )
  ),
  tags$br(),
  downloadButton("save_bim", "Save .bim file (PLINK variant information file)"),
  htmlOutput("message"),
  tags$br(),
  tabsetPanel(
    tabPanel(
      h4("Basic statistics"),
      h4("Performed by PLINK 2.0 ( ", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#sample_counts", target = "_blank", "--sample-counts;"), a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#missing", target = "_blank", "--missing"), ") and,", span("in the case that LD-based pruning was selected,", style = "color:#FF6347"), "by PLINK 2.0 (", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#het", target = "_blank", "--het"), ") and PLINK 1.9 (", a(href = "https://www.cog-genomics.org/plink/1.9/basic_stats#ibc", target = "_blank", "--ibc"), ") "),
      radioButtons("dataset_type","Datasets:", choices = c("Original", "After filtering"), inline = T),
      conditionalPanel(condition = "input.dataset_type=='Original'",
        radioButtons("bs_reports_orig","Reports:", choices = c("Sample variant-count report", "Sample-based missing data report"), inline = T),
      ),
      conditionalPanel(condition = "input.dataset_type=='After filtering'",
        radioButtons("bs_reports","Reports:", choices = c(reports_list), inline = T),
      ),
      conditionalPanel(condition = "(input.dataset_type=='Original' && input.bs_reports_orig=='Sample variant-count report') || (input.dataset_type=='After filtering' && input.bs_reports=='Sample variant-count report')",
        tags$span(id = "param_title", "Sample variant-counts"),
        tags$span("( performed by PLINK 2.0", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#sample_counts", target = "_blank", "--sample-counts"), "command)"),
        tags$br(),
        tags$span(id = "comment_text", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#sample_counts", target = "_blank", "--sample-counts"), "reports the number of observed variants (relative to the reference genome) per sample, subdivided into various classes."),
        tags$br()
      ),
      conditionalPanel(condition = "(input.dataset_type=='Original' && input.bs_reports_orig=='Sample-based missing data report') || (input.dataset_type=='After filtering' && input.bs_reports=='Sample-based missing data report')",
        tags$span(id = "param_title", "Missing data"),
        tags$span("( performed by PLINK 2.0", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#missing", target = "_blank", "--missing sample-only"), "command)"),
        tags$br(),
        tags$span(id = "comment_text", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#missing", target = "_blank", "--missing sample-only"), "produces a sample-based missing data report."),
        tags$br()
      ),
      conditionalPanel(condition = "input.dataset_type=='After filtering' && input.bs_reports=='Method-of-moments F coefficient estimates'",
        tags$span(id = "param_title", "Inbreeding (Method-of-moments F coefficient estimates)"),
        tags$span("( performed by PLINK 2.0", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#het", target = "_blank", "--het"), "command)"),
        tags$br(),
        tags$span(id = "comment_text", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#het", target = "_blank", "--het"), "computes observed and expected homozygous/heterozygous genotype counts for each sample, and reports method-of-moments F coefficient estimates (i.e. (1 - (<observed het. count> / <expected het. count>)))."),
        tags$br()
      ),
      conditionalPanel(condition = "input.dataset_type=='After filtering' && input.bs_reports=='GCTA inbreeding coefficient report'",
        tags$span(id = "param_title", "Inbreeding (GCTA inbreeding coefficient report)"),
        tags$span("( performed by PLINK 1.9", a(href = "https://www.cog-genomics.org/plink/1.9/basic_stats#ibc", target = "_blank", "--ibc"), "command)"),
        tags$br(),
        tags$span(id = "comment_text", a(href = "https://www.cog-genomics.org/plink/1.9/basic_stats#ibc", target = "_blank", "--ibc"), " (ported from", a(href = "https://cnsgenomics.com/software/gcta/", target = "_blank", "GCTA"), ") calculates three inbreeding coefficients for each sample and writes a report."),
        tags$br()
      ),
      tags$span(textOutput("variants_number"), style = "color:#008080;font-weight:bold"),
      tags$br(),
      radioButtons("output_type","Views:", choices = c("Table", "Chart"), inline = T),
      conditionalPanel(condition = "input.output_type=='Table'",
        DT::dataTableOutput("bs_tbl"),
        conditionalPanel(condition = "(input.dataset_type=='Original' && input.bs_reports_orig=='Sample variant-count report') || (input.dataset_type=='After filtering' && input.bs_reports=='Sample variant-count report')",
          tags$span(id = "param_title", "Column contents:"),
          tags$br(),
          fluidRow(
            column(12,
              span(id = "comment2_text", "SAMPLE_ID: "),
              span(id = "comment_text", "Sample ID")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "HOM_REF_CT: "),
              span(id = "comment_text", "Hom-REF genotype count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "HOM_ALT_SNP_CT: "),
              span(id = "comment_text", "Hom-ALT SNP (single-character REF and ALT) count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "HET_SNP_CT: "),
              span(id = "comment_text", "Het. SNP genotype count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "DIPLOID_TRANSITION_CT: "),
              span(id = "comment_text", "Diploid SNP transition (A<->G, C<->T) count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "DIPLOID_TRANSVERSION_CT: "),
              span(id = "comment_text", "Diploid SNP transversion count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "DIPLOID_NONSNP_NONSYMBOLIC_CT: "),
              span(id = "comment_text", "Diploid non-SNP, non-symbolic variant count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "DIPLOID_SINGLETON_CT: "),
              span(id = "comment_text", "Number of singletons relative to this dataset, considering just diploid calls")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "HAP_REF_CT: "),
              span(id = "comment_text", "Haploid REF count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "HAP_ALT_CT: "),
              span(id = "comment_text", "Haploid ALT count")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "MISSING_CT: "),
              span(id = "comment_text", "Missing call count")
            )
          )
        ),
        conditionalPanel(condition = "(input.dataset_type=='Original' && input.bs_reports_orig=='Sample-based missing data report') || (input.dataset_type=='After filtering' && input.bs_reports=='Sample-based missing data report')",
          tags$span(id = "param_title", "Column contents:"),
          fluidRow(
            column(12,
              span(id = "comment2_text", "SAMPLE_ID: "),
              span(id = "comment_text", "Sample ID")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "MISSING_CT: "),
              span(id = "comment_text", "Number of missing hardcalls, not counting het haploids")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "OBS_CT: "),
              span(id = "comment_text", "Denominator (total number of variants observed)")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "F_MISS: "),
              span(id = "comment_text", "Missing hardcall rate, not counting het haploids")
            )
          )
        ),
        conditionalPanel(condition = "input.dataset_type=='After filtering' && input.bs_reports=='Method-of-moments F coefficient estimates'",
          tags$span(id = "param_title", "Column contents:"),
          fluidRow(
            column(12,
              span(id = "comment2_text", "SAMPLE_ID: "),
              span(id = "comment_text", "Sample ID")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "O_HOM: "),
              span(id = "comment_text", "Observed number of homozygous genotypes")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "E_HOM: "),
              span(id = "comment_text", "Expected number of homozygous genotypes")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "O_HET: "),
              span(id = "comment_text", "Observed number of heterozygous genotypes")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "E_HET: "),
              span(id = "comment_text", "Expected number of heterozygous genotypes")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "OBS_CT: "),
              span(id = "comment_text", "Number of (nonmissing, non-monomorphic) autosomal genotype observations")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "F: "),
              span(id = "comment_text", "Method-of-moments F coefficient estimate")
            )
          )
        ),
        conditionalPanel(condition = "input.dataset_type=='After filtering' && input.bs_reports=='GCTA inbreeding coefficient report'",
          tags$span(id = "param_title", "Column contents:"),
          fluidRow(
            column(12,
              span(id = "comment2_text", "SAMPLE_ID: "),
              span(id = "comment_text", "Sample ID")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "NOMISS: "),
              span(id = "comment_text", "Number of non-missing genotype calls")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "Fhat1: "),
              span(id = "comment_text", "Variance-standardized relationship minus 1")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "Fhat2: "),
              span(id = "comment_text", "Excess homozygosity-based inbreeding estimate (same as PLINK --het)")
            )
          ),
          fluidRow(
            column(12,
              span(id = "comment2_text", "Fhat3: "),
              span(id = "comment_text", "Estimate based on correlation between uniting gametes")
            )
          )
        ),
        tags$br()
      ),
      conditionalPanel(condition = "input.output_type=='Chart'",
        conditionalPanel(condition = "(input.dataset_type=='Original' && input.bs_reports_orig=='Sample variant-count report') || (input.dataset_type=='After filtering' && input.bs_reports=='Sample variant-count report')",
          plotlyOutput("view_vc", height = "800px", inline = FALSE)
        ),
        conditionalPanel(condition = "(input.dataset_type=='Original' && input.bs_reports_orig=='Sample-based missing data report') || (input.dataset_type=='After filtering' && input.bs_reports=='Sample-based missing data report')",
          plotlyOutput("view_miss", height = "800px", inline = FALSE)
        ),
        conditionalPanel(condition = "input.dataset_type=='After filtering' && input.bs_reports=='Method-of-moments F coefficient estimates'",
          plotlyOutput("view_het", height = "800px", inline = FALSE)
        ),
        conditionalPanel(condition = "input.dataset_type=='After filtering' && input.bs_reports=='GCTA inbreeding coefficient report'",
          plotlyOutput("view_ibc", height = "800px", inline = FALSE)
        ),
        tags$br()
      ),
      conditionalPanel(condition = "input.output_type=='Table'",
        downloadButton("save_text_bs", "Save data as a zip file")
      ),
      conditionalPanel(condition = "input.output_type=='Chart'",
        downloadButton("save_bs", "Save a chart as a standalone HTML file"),
      ),
      tags$br(),
      tags$br()
    ),
    tabPanel(
      h4("Population Stratification analysis"),
      h4("Performed by PLINK 2.0 ( PCA:", a(href = "https://www.cog-genomics.org/plink/2.0/strat#pca", target = "_blank", "--pca"), psa_tools, "and PLINK 1.9 ( MDS:", a(href = "https://www.cog-genomics.org/plink/1.9/strat#cluster", target = "_blank", "--cluster"), a(href = "https://www.cog-genomics.org/plink/1.9/strat#mds_plot", target = "_blank", "--mds-plot"), ")"),
      tags$span(id = "comment_text", "PLINK provides two dimension reduction routines: --pca, for principal components analysis (PCA) based on the variance-standardized relationship matrix,"),
      tags$br(),
      tags$span(id = "comment_text", "and --mds-plot, for multidimensional scaling (MDS) based on raw Hamming distances."),
      tags$br(),
      tags$span(cluster_com, style = "color:#FF6347;font-weight:bold"),
      tags$br(),
      radioButtons("data_type_pca","Methods:", choices = c("PCA", "Normalized PCs", "MDS"), inline = T),
      conditionalPanel(condition = "input.data_type_pca=='PCA'",
        h5("Principle Component Analysis (PCA) (Eigenvectors)"),
        tags$span(id = "comment_text", a(href = "https://www.cog-genomics.org/plink/2.0/strat#pca", target = "_blank", "--pca"), " extracts the top 20 principal components of the variance-standardized relationship matrix computed by PLINK 2.0 ", a(href = "https://www.cog-genomics.org/plink/2.0/distance#make_rel", target = "_blank", "--make-rel"), "."),
        tags$br(),
        tags$span(id = "comment_text", "Since this is based on the relationship matrix, it is critical to remove very-low-MAF variants before performing this computation."),
        tags$br()
      ),
      conditionalPanel(condition = "input.data_type_pca=='Normalized PCs'",
        h5("Normalized PCs (each eigenvector is multiplied by the square root of its eigenvalue)")
      ),
      conditionalPanel(condition = "input.data_type_pca=='MDS'",
        h5("Multidimensional Scaling (MDS)"),
        tags$span(id = "comment_text", a(href = "https://www.cog-genomics.org/plink/1.9/strat#mds_plot", target = "_blank", "--mds-plot <dimension count>"), " By default, multidimensional scaling is performed on an inter-sample distance matrix.", a(href = "https://www.cog-genomics.org/plink/1.9/distance", target = "_blank", "--distance"), "."),
        tags$br(),
        tags$span(id = "comment_text", "The default, singular value decomposition-based algorithm is designed to give the same results as PLINK 1.07 and the R cmdscale (Classical Metric Multidimensional Scaling) function."),
        tags$br()
      ),
      fluidRow(
        column(3, selectInput(inputId = "component_x", label = "Component (X axis):", choices = c(1:10))),
        column(3, selectInput(inputId = "component_y", label = "Component (Y axis):", choices = c(1:10), selected = "2"))
      ),
      h5(textOutput("selected_comp_pca")),
      selectInput(inputId = "smps_pca", label = "List of Sample ID/Name:", choices = c("ALL", sort(as.character(smp[,2])))),
      radioButtons("display_sam_name","Samples IDs/Names:", choices = c("Hide", "Display"), inline = T),
      plotlyOutput("view_pca", width = "1000px", height = "1000px", inline = FALSE),
      tags$br(),
      fluidRow(
      downloadButton("save_psa", "Save a plot as a standalone HTML file"),
      downloadButton("save_text_psa", "Save data as a zip file")
      ),
      tags$br(),
      tags$br()
    ),
    tabPanel(
      h4("Wright's FST estimation"),
      h4("Performed by PLINK 2.0 ( Pairwise fixation index:", a(href = "https://www.cog-genomics.org/plink/2.0/basic_stats#fst", target = "_blank", "--fst"), ")"),
      tags$span(id = "comment_text", " --fst computes Wright's FST estimates between each pair of populations (clusters or groups)."),
      tags$br(),
      tags$span(id = "comment_text", "FST estimates were computed using the method introduced in  Bhatia G, Patterson N, Sankararaman S, Price AL (2013)", a(href = "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3759727/", target = "_blank", "\"Estimating and interpreting FST: The impact of rare variants\".")),
      tags$br(),
      tags$br(),
      selectInput(inputId = "cls_pairs", label = cls_pairs_lab, choices = groups_pairs, selected = "0-1"),
      span(toString(unique_groups[,1]), style = "color:#FF6347;font-weight:bold"),
      fluidRow(
        column(12,
          span(id = "param_title", "Wright's FST value "),
          span(id = "fst_val", textOutput("selected_clusters"))
        )
       ),
      tags$span(id = "comment2_text", "This plot shows only chromosomes/contigs with variants greater than or equal to 100 and less than or equal to 100,000."),
      tags$br(),
      tags$span(id = "comment2_text", "Variants with \'nan\' Fst values were removed, and negative FST values are truncated to 0."),
      tags$br(),
      selectInput(inputId = "chr_no_fst", label = "Chromosome/Contig number/name:", choices = fst_contigs_list),
      selectInput(inputId = "min_fst_val", label = "Minimum FST value:", choices = c(0, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)),
      tags$br(),
      plotlyOutput("view_fst", width = "100%", height = "600px", inline = FALSE),
      tags$br(),
      fluidRow(
        downloadButton("save_fst", "Save a plot as a standalone HTML file"),
        downloadButton("save_text_fst", "Save original data for a selected pair of subpopulations as a zip file"),
      ),
      tags$br(),
      tags$br()
    ),
    tabPanel(
      h4("IBS and GRM calculation & Kinship Coefficients estimation"),
      h4("Performed by PLINK 1.9 (", a(href = "https://www.cog-genomics.org/plink/1.9/distance#distance", target = "_blank", "--distance ibs"), ")", "and PLINK 2.0 (", a(href = "https://www.cog-genomics.org/plink/2.0/distance#make_rel", target = "_blank", "--make-rel;"), a(href = "https://www.cog-genomics.org/plink/2.0/distance#make_king", target = "_blank", "--make-king"), ")"),
      radioButtons("data_type_ksh", "Methods:", choices = c("IBS matrix", "Relationship matrix", "KING-robust kinship"), inline = T),
      conditionalPanel(condition = "input.data_type_ksh=='IBS matrix'",
        tags$span(id = "param_title", "IBS (Identity-by-state/Hamming distance) matrix "),
        tags$span("( performed by PLINK 1.9 IBS and Hamming distance calculation engine: ", a(href = "https://www.cog-genomics.org/plink/1.9/distance#distance", target = "_blank", "--distance ibs"), ")"),
        tags$br(),
        tags$span(id = "comment_text", "By default, distances are expressed as allele counts. 'ibs' causes an identity-by-state matrix to be written to plink.mibs.")
    ),
      conditionalPanel(condition = "input.data_type_ksh=='Relationship matrix'",
        tags$span(id = "param_title", "Variance-standardized relationship matrix"),
        tags$span(id = "comment_text", "(Genetic Relationship Matrix, GRM)"),
        tags$span("( performed by PLINK 2.0 relationship matrix calculator: ", a(href = "https://www.cog-genomics.org/plink/2.0/distance#make_rel", target = "_blank", "--make-rel"), grm_tool),
        tags$br(),
        tags$span(id = "comment_text", "This relationship matrix calculator (", a(href = "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3014363/", target = "_blank", "Yang et al., 2011"), ") can be used to reliably identify close relations within a single population, if the MAFs are decent."),
        tags$br(),
        tags$span(id = "comment_text", "It is critical to remove very-low-MAF variants before performing this computation."),
        tags$br(),
        tags$span(id = "comment2_text", "In this chart, negative relatedness values are truncated to 0. The relationship values for self-self pairs are set to 1.0.")
      ),
      conditionalPanel(condition = "input.data_type_ksh=='KING-robust kinship'",
        tags$span(id = "param_title", "KING-robust kinship"),
        tags$span("( performed by PLINK 2.0 KING-robust kinship estimator: ", a(href = "https://www.cog-genomics.org/plink/2.0/distance#make_king", target = "_blank", "--make-king"), ")"),
        tags$br(),
        tags$span(id = "comment_text", "This KING-robust kinship estimator (", a(href = "https://www.ncbi.nlm.nih.gov/pubmed/20926424", target = "_blank", "Manichaikul et al., 2010"), ") can be mostly trusted on mixed-population datasets, and doesn't require MAFs."),
        tags$br(),
        tags$span(id = "comment_text", "Note that KING kinship coefficients are scaled such that duplicate samples have kinship 0.5, not 1."),
        tags$br(),
        tags$span(id = "comment2_text", "In this chart, negative KING-robust kinship coefficient estimates are truncated to 0.")
      ),
      tags$br(),
      radioButtons("sort_order","Sorted by:", choices = c("PLINK Sample ID", "Group/Cluster number"), inline = T),
      plotlyOutput("view_ksh", width = "1000px", height = "1000px", inline = FALSE),
      tags$br(),
      fluidRow(
        downloadButton("save_ksh", "Save a chart as a standalone HTML file"),
        downloadButton("save_text_ksh", "Save data as a zip file")
      ),
      tags$br(),
      tags$br()
    )
  )
)

server <- function(input, output, session) {

  output$save_bim <- downloadHandler(
    filename = function() {
      paste("variants_data", "bim", sep = ".")
    },
    content = function(file) {
      file.copy("data/results_data.bim", file)
    }
  )

  output$message <- renderUI(
    if (u_parameters[1,20] == 1) {
    HTML(
      paste(c("<span style='color:#FF6347;font-weight:bold'>", message_txt, "</span>"), collapse = "<br>")
    )
    } else {
      HTML("<br>")
    }
  )

# Basic statistics

  output$variants_number <- renderText({
    if (input$dataset_type == "Original") {
      sprintf("Number of variants used in analysis (total number of variants observed in samples): %s; Number of analyzed samples: %s", u_parameters[1,15], smps_orig_number)
    } else if (input$dataset_type == "After filtering") {
      if (input$bs_reports == "Sample variant-count report" || input$bs_reports == "Sample-based missing data report") {
        sprintf("Number of variants used in analysis (remained after filtering): %s; Number of analyzed samples: %s", u_parameters[1,16], smps_number)
      } else if (input$bs_reports == "Method-of-moments F coefficient estimates" || input$bs_reports == "GCTA inbreeding coefficient report") {
        sprintf("Number of variants used in analysis (remained after filtering and LD pruning): %s; Number of analyzed samples: %s", u_parameters[1,17], smps_number)
      }
    }
  })

  bs_data <- reactive({
    if (input$dataset_type == "Original") {
      if (input$bs_reports_orig == "Sample variant-count report") {
        dt_bs <- data.frame(SAMPLE_ID = as.character(smp_orig[,2]), HOM_REF_CT  = as.numeric(sample_counts_matrix[,2]), HOM_ALT_SNP_CT = as.numeric(sample_counts_matrix[,3]), HET_SNP_CT = as.numeric(sample_counts_matrix[,4]), DIPLOID_TRANSITION_CT = as.numeric(sample_counts_matrix[,5]), DIPLOID_TRANSVERSION_CT = as.numeric(sample_counts_matrix[,6]), DIPLOID_NONSNP_NONSYMBOLIC_CT = as.numeric(sample_counts_matrix[,7]), DIPLOID_SINGLETON_C = as.numeric(sample_counts_matrix[,8]), HAP_REF_CT = as.numeric(sample_counts_matrix[,9]), HAP_ALT_CT = as.numeric(sample_counts_matrix[,10]), MISSING_CT = as.numeric(sample_counts_matrix[,11])) %>% dplyr::arrange(SAMPLE_ID)
      } else if (input$bs_reports_orig == "Sample-based missing data report") {
        dt_bs <- data.frame(SAMPLE_ID = as.character(smp_orig[,2]), MISSING_CT  = as.numeric(missing_data_matrix[,2]), OBS_CT = as.numeric(missing_data_matrix[,3]), F_MISS = as.numeric(missing_data_matrix[,4])) %>% dplyr::arrange(SAMPLE_ID)
      }
    } else if (input$dataset_type == "After filtering") {
      if (input$bs_reports == "Sample variant-count report") {
        dt_bs <- data.frame(SAMPLE_ID = as.character(smp[,2]), HOM_REF_CT  = as.numeric(sample_counts_af_matrix[,2]), HOM_ALT_SNP_CT = as.numeric(sample_counts_af_matrix[,3]), HET_SNP_CT = as.numeric(sample_counts_af_matrix[,4]), DIPLOID_TRANSITION_CT = as.numeric(sample_counts_af_matrix[,5]), DIPLOID_TRANSVERSION_CT = as.numeric(sample_counts_af_matrix[,6]), DIPLOID_NONSNP_NONSYMBOLIC_CT = as.numeric(sample_counts_af_matrix[,7]), DIPLOID_SINGLETON_C = as.numeric(sample_counts_af_matrix[,8]), HAP_REF_CT = as.numeric(sample_counts_af_matrix[,9]), HAP_ALT_CT = as.numeric(sample_counts_af_matrix[,10]), MISSING_CT = as.numeric(sample_counts_af_matrix[,11])) %>% dplyr::arrange(SAMPLE_ID)
      } else if (input$bs_reports == "Sample-based missing data report") {
        dt_bs <- data.frame(SAMPLE_ID = as.character(smp[,2]), MISSING_CT  = as.numeric(missing_data_af_matrix[,2]), OBS_CT = as.numeric(missing_data_af_matrix[,3]), F_MISS = as.numeric(missing_data_af_matrix[,4])) %>% dplyr::arrange(SAMPLE_ID)
      } else if (input$bs_reports == "Method-of-moments F coefficient estimates") {
        dt_bs <- data.frame(SAMPLE_ID = as.character(smp[,2]), O_HOM  = as.numeric(het_matrix[,2]), E_HOM = as.numeric(het_matrix[,3]), O_HET  = as.numeric(het_matrix[,4]), E_HET  = as.numeric(het_matrix[,5]), OBS_CT = as.numeric(het_matrix[,6]), F = as.numeric(het_matrix[,7])) %>% dplyr::arrange(SAMPLE_ID)
      } else if (input$bs_reports == "GCTA inbreeding coefficient report") {
        dt_bs <- data.frame(SAMPLE_ID = as.character(smp[,2]), NOMISS  = as.numeric(ibc_matrix[,3]), Fhat1 = as.numeric(ibc_matrix[,4]), Fhat2 = as.numeric(ibc_matrix[,5]), Fhat3 = as.numeric(ibc_matrix[,6])) %>% dplyr::arrange(SAMPLE_ID)
      }
    }
  })

  output$bs_tbl <- DT::renderDataTable({
    DT::datatable(bs_data())
  })

  dataset_input_vc <- reactive({
    if ((input$dataset_type == "Original" && input$bs_reports_orig == "Sample variant-count report") || (input$dataset_type == "After filtering" && input$bs_reports == "Sample variant-count report")) {
      plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`HOM_REF_CT`, type = "bar", name = "Hom-REF genotype count") %>%
      add_trace(y = ~`HOM_ALT_SNP_CT`, name = "Hom-ALT SNP count") %>%
      add_trace(y = ~`HET_SNP_CT`, name = "Het. SNP genotype count") %>%
      add_trace(y = ~`DIPLOID_NONSNP_NONSYMBOLIC_CT`, name = "Diploid non-SNP variant count") %>%
      add_trace(y = ~`HAP_REF_CT`, name = "Haploid REF count") %>%
      add_trace(y = ~`HAP_ALT_CT`, name = "Haploid ALT count") %>%
      add_trace(y = ~`MISSING_CT`, name = "Missing call count") %>%
      layout(barmode = "stack", paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = "Sample variant-count report", font = list(family = "sans serif", size = 20, color = "#C71585")),
        font = list(family = "sans serif", size = 14, color = "#4B0082"), margin = 1, xaxis = list(title = "Sample ID", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")), yaxis = list(title = "Count", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000"))) %>%
      config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "sample_variant_count_chart", width = 1000, height = 600))
    }
  })

  dataset_input_miss <- reactive({
    if ((input$dataset_type == "Original" && input$bs_reports_orig == "Sample-based missing data report") || (input$dataset_type == "After filtering" && input$bs_reports == "Sample-based missing data report")) {
      bar_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`OBS_CT`, type = "bar", name = "Total number of variants observed") %>%
      add_trace(y = ~`MISSING_CT`, name = "Number of missing hardcalls") %>%
      layout(yaxis = list(title = "Count", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")), barmode = "group")
      line_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`F_MISS`, type = "scatter", mode = "lines+markers", name = "Missing hardcall rate (F_MISS)") %>%
      layout(yaxis = list(title = "F_MISS", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")))
      subplot(bar_plot, line_plot, nrows = 2, shareX = TRUE, titleY = TRUE) %>%
      layout(paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = "Sample-based missing data report", font = list(family = "sans serif", size = 20, color = "#C71585")),
        font = list(family = "sans serif", size = 14, color = "#4B0082"), margin = 1, xaxis = list(title = "Sample ID", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000"))) %>%
      config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "sample_missing_data_chart", width = 1000, height = 800))
    }
  })

  dataset_input_het <- reactive({
    if (input$dataset_type == "After filtering" && input$bs_reports == "Method-of-moments F coefficient estimates") {
      bar_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`OBS_CT`, type = "bar", name = "Number of nonmissing autosomal genotype observations") %>%
      add_trace(y = ~`O_HOM`, name = "Observed number of homozygous genotypes") %>%
      add_trace(y = ~`E_HOM`, name = "Expected number of homozygous genotypes") %>%
      add_trace(y = ~`O_HET`, name = "Observed number of heterozygous genotypes") %>%
      add_trace(y = ~`E_HET`, name = "Expected number of heterozygous genotypes") %>%
      layout(yaxis = list(title = "Count", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")), barmode = "group")
      line_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`F`, type = "scatter", mode = "lines+markers", name = "Method-of-moments F coefficient estimate (F)") %>%
      layout(title = "F", yaxis = list(ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")))
      subplot(bar_plot, line_plot, nrows = 2, shareX = TRUE, titleY = TRUE) %>%
      layout(paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = "Method-of-moments F coefficient estimates", font = list(family = "sans serif", size = 20, color = "#C71585")),
        font = list(family = "sans serif", size = 14, color = "#4B0082"), margin = 1, xaxis = list(title = "Sample ID", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000"))) %>%
      config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "F_coefficient_chart", width = 1000, height = 800))
    }
  })

  dataset_input_ibc <- reactive({
    if (input$dataset_type == "After filtering" && input$bs_reports == "GCTA inbreeding coefficient report") {
      bar_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`NOMISS`, type = "bar", name = "Number of non-missing genotype calls") %>%
      layout(yaxis = list(title = "Count", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")))
      line1_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`Fhat1`, type = "scatter", mode = "lines+markers", name = "Variance-standardized relationship minus 1 (Fhat1)") %>%
      layout(title = "Fhat1", yaxis = list(ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")))
      line2_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`Fhat2`, type = "scatter", mode = "lines+markers", name = "Excess homozygosity-based inbreeding estimate (Fhat2)") %>%
      layout(title = "Fhat2", yaxis = list(ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")))
      line3_plot <- plot_ly(bs_data(), x = ~`SAMPLE_ID`, y = ~`Fhat3`, type = "scatter", mode = "lines+markers", name = "Estimate based on correlation between uniting gametes (Fhat3)") %>%
      layout(title = "Fhat3", yaxis = list(ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")))
      subplot(bar_plot, line1_plot, line2_plot, line3_plot, nrows = 4, shareX = TRUE, titleY = TRUE) %>%
      layout(paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = "GCTA inbreeding coefficient report", font = list(family = "sans serif", size = 20, color = "#C71585")),
        font = list(family = "sans serif", size = 14, color = "#4B0082"), margin = 1, xaxis = list(title = "Sample ID", ticklen = 5, tickfont = list(family = "sans serif", color = "#800000"))) %>%
      config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "inbreeding_coefficient_chart", width = 1000, height = 800))
    }
  })

  output$view_vc <- renderPlotly({
    dataset_input_vc()
  })

  output$view_miss <- renderPlotly({
    dataset_input_miss()
  })

  output$view_het <- renderPlotly({
    dataset_input_het()
  })

  output$view_ibc <- renderPlotly({
    dataset_input_ibc()
  })

  output$save_bs <- downloadHandler(
    filename = function() {
      paste("basic_stat_chart", "html", sep = ".")
    },
    content = function(file) {
      if ((input$dataset_type == "Original" && input$bs_reports_orig == "Sample variant-count report") || (input$dataset_type == "After filtering" && input$bs_reports == "Sample variant-count report")) {
        htmlwidgets::saveWidget(as_widget(dataset_input_vc()), "basic_stat_t_chart.html")
      } else if ((input$dataset_type == "Original" && input$bs_reports_orig == "Sample-based missing data report") || (input$dataset_type == "After filtering" && input$bs_reports == "Sample-based missing data report")) {
        htmlwidgets::saveWidget(as_widget(dataset_input_miss()), "basic_stat_t_chart.html")
      } else if (input$dataset_type == "After filtering" && input$bs_reports == "Method-of-moments F coefficient estimates") {
        htmlwidgets::saveWidget(as_widget(dataset_input_het()), "basic_stat_t_chart.html")
      } else if (input$dataset_type == "After filtering" && input$bs_reports == "GCTA inbreeding coefficient report") {
        htmlwidgets::saveWidget(as_widget(dataset_input_ibc()), "basic_stat_t_chart.html")
      }
      file.copy("basic_stat_t_chart.html", file)
    }
  )

  output$save_text_bs <- downloadHandler(
    filename = function() {
      paste0("basic_stat_data", ".zip")
    },
    content = function(file) {
      files <- NULL
      if (u_parameters[1,6] == "yes") {
        for (i in 1:6) {
          if (i == 1) {
            files <- c("data/plink_sample_counts.scount",files)
          } else if (i == 2) {
            files <- c("data/plink_sample_counts_af.scount",files)
          } else if (i == 3) {
            files <- c("data/plink_missing.smiss",files)
          } else if (i == 4) {
            files <- c("data/plink_missing_af.smiss",files)
          } else if (i == 5) {
            files <- c("data/plink_het.het",files)
          } else if (i == 6) {
            files <- c("data/plink_ibc.ibc",files)
          }
        }
       } else {
        for (i in 1:4) {
          if (i == 1) {
            files <- c("data/plink_sample_counts.scount",files)
          } else if (i == 2) {
            files <- c("data/plink_sample_counts_af.scount",files)
          } else if (i == 3) {
            files <- c("data/plink_missing.smiss",files)
          } else if (i == 4) {
            files <- c("data/plink_missing_af.smiss",files)
          }
        }
      }
      zip(file,files)
    }
  )

  # Population Stratification analysis

  vals <- reactiveValues()
  observe({
    if (input$data_type_pca == "PCA") {
      vals$comp_x <- as.numeric(input$component_x) + 1
      vals$comp_y <- as.numeric(input$component_y) + 1
      vals$c1vec <- as.vector(as.numeric(pca_data_matrix[,vals$comp_x]))
      vals$c2vec <- as.vector(as.numeric(pca_data_matrix[,vals$comp_y]))
      vals$title_str <- sprintf("Principal Components Analysis (PCA): PC%s vs. PC%s", input$component_x, input$component_y)
    } else if (input$data_type_pca == "Normalized PCs") {
      vals$comp_x <- as.numeric(input$component_x) + 1
      vals$comp_y <- as.numeric(input$component_y) + 1
      vals$c1vec <- as.vector(as.numeric(pcs_norm_data_matrix[,vals$comp_x]))
      vals$c2vec <- as.vector(as.numeric(pcs_norm_data_matrix[,vals$comp_y]))
      vals$title_str <- sprintf("Normalized PCs: PC%s vs. PC%s", input$component_x, input$component_y)
    } else if (input$data_type_pca == "MDS") {
      vals$comp_x <- as.numeric(input$component_x) + 3
      vals$comp_y <- as.numeric(input$component_y) + 3
      vals$c1vec <- as.vector(as.numeric(mds_data_matrix[,vals$comp_x]))
      vals$c2vec <- as.vector(as.numeric(mds_data_matrix[,vals$comp_y]))
      vals$title_str <- sprintf("Multidimensional Scaling (MDS): C%s vs. C%s", input$component_x, input$component_y)
    }
  })

  vals2 <- reactiveValues()
  observe({
    vals2$xmin <- as.numeric(min(vals$c1vec) - abs(min(vals$c1vec)) / 3)
    vals2$xmax <- as.numeric(max(vals$c1vec) + abs(max(vals$c1vec)) / 3)
    vals2$ymin <- as.numeric(min(vals$c2vec) - abs(min(vals$c2vec)) / 3)
    vals2$ymax <- as.numeric(max(vals$c2vec) + abs(max(vals$c2vec)) / 3)
  })

  output$selected_comp_pca <- renderText({
    if (input$data_type_pca == "PCA" || input$data_type_pca == "Normalized PCs") {
      if (u_parameters[1,11] == "yes") {
        sprintf("Plot of the PC%s (X axis) and PC%s (Y axis) principal components (colored by clusters)", input$component_x, input$component_y)
      } else if (u_parameters[1,11] == "no") {
        sprintf("Plot of the PC%s (X axis) and PC%s (Y axis) principal components (colored by groups)", input$component_x, input$component_y)
      }
    } else if (input$data_type_pca == "MDS") {
      if (u_parameters[1,11] == "yes") {
        sprintf("Plot of the C%s (X axis) and C%s (Y axis) components (colored by clusters)", input$component_x, input$component_y)

      } else if (u_parameters[1,11] == "no") {
        sprintf("Plot of the C%s (X axis) and C%s (Y axis) components (colored by groups)", input$component_x, input$component_y)
      }
    }
  })

  ps_data_pca <- reactive({
      if (input$smps_pca == "ALL") {
        df_pca <- data.frame(SampleId = smp[,2], C1 = vals$c1vec, C2 = vals$c2vec, ClusterNo = as.character(clusters[,2]), ps = 1)
      } else if (input$smps_pca != "ALL") {
        Sample_id_val <- as.character(input$smps_pca)
        ps_vec <- c()
        for (i in seq(1, nrow(smp), by = 1)) {
          if (smp[i,2] == Sample_id_val) {
            ps_vec <- c(ps_vec, 2)
          } else {
            ps_vec <- c(ps_vec, 1)
          }
        }
        df_pca <- data.frame(SampleId = smp[,2], C1 = vals$c1vec, C2 = vals$c2vec, ClusterNo = as.character(clusters[,2]), ps = ps_vec)
      }
  })

  vals_pca_pl <- reactiveValues()
  observe({
    if (input$data_type_pca == "PCA") {
      component_x_int <- as.numeric(input$component_x) 
      component_y_int <- as.numeric(input$component_y) 
      pve_comp_x <- pca_eigenvalues[component_x_int,1] / as.numeric(u_parameters[1,18]) * 100
      pve_comp_y <- pca_eigenvalues[component_y_int,1] / as.numeric(u_parameters[1,18]) * 100
      vals_pca_pl$xtitle <- paste0(sprintf("Principal Component %s (PC%s) (%.1f", input$component_x, input$component_x, pve_comp_x), "%)")
      vals_pca_pl$ytitle <- paste0(sprintf("Principal Component %s (PC%s) (%.1f", input$component_y, input$component_y, pve_comp_y), "%)")
    } else if (input$data_type_pca == "Normalized PCs") {
      vals_pca_pl$xtitle <- sprintf("Principal Component %s (PC%s)", input$component_x, input$component_x)
      vals_pca_pl$ytitle <- sprintf("Principal Component %s (PC%s)", input$component_y, input$component_y)
    } else if (input$data_type_pca == "MDS") {
      vals_pca_pl$xtitle <- sprintf("Component %s (C%s)", input$component_x, input$component_x)
      vals_pca_pl$ytitle <- sprintf("Component %s (C%s)", input$component_y, input$component_y)
    }
  })

  display_sam_name <- reactive({
    if (input$display_sam_name == "Hide") {
      dis <- FALSE
    } else if (input$display_sam_name == "Display") {
      dis <- TRUE
    }
  })

  dataset_input_pca <- reactive({
    plot_ly(ps_data_pca(), type = "scatter", mode = "markers", colors = psa_pl_col, sizes = c(7,21), fill = ~'') %>%
    add_markers(x = ~`C1`, y = ~`C2`, color = ~`ClusterNo`, size = ~`ps`,
      marker = list(symbol = "circle", sizemode = "diameter", opacity = 0.7),
      textposition = "auto",
      hoverinfo = "text",
      hovertext = ~paste(sep='',
        "Sample ID: ", `SampleId`,
        "<br>Component: ", round(`C1`,3),
        "<br>Component: ", round(`C2`,3),
        "<br>Cluster/Group No: ", `ClusterNo`)) %>%
    layout(paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = vals$title_str, font = list(family = "sans serif", size = 20, color = "#C71585")),
      font = list(family = "sans serif", size = 14, color = "#4B0082"), margin = 1, hovermode = "closest", hoverdistance = 1,
      xaxis = list(title = vals_pca_pl$xtitle, range = c(vals2$xmin, vals2$xmax), showgrid = TRUE, gridwith = 1, zerolinewidth = 1, ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")),
      yaxis = list(title = vals_pca_pl$ytitle, range = c(vals2$ymin, vals2$ymax), showgrid = TRUE, gridwith = 1, zerolinewidth = 1, ticklen = 5, tickfont = list(family = "sans serif", color = "#800000")), showlegend = TRUE) %>%
    config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "psa_chart", width = 1000, height = 1000))
  })

  output$view_pca <- renderPlotly({
    dataset_input_pca() %>%
    add_trace(
      x = ~`C1`, y = ~`C2`,
      mode = "text",
      textposition = "top center",
      text = ~`SampleId`,
      textfont = list(color = "#4419CC", size = 11),
      showlegend = FALSE,
      visible = display_sam_name()
    )
  })

  output$save_psa <- downloadHandler(
    filename = function() {
      paste("psa_chart", "html", sep = ".")
    },
    content = function(file) {
      htmlwidgets::saveWidget(as_widget(dataset_input_pca()), "psa_t_chart.html")
      file.copy("psa_t_chart.html", file)
    }
  )

  output$save_text_psa <- downloadHandler(
    filename = function() {
      paste0("psa_data", ".zip")
    },
    content = function(file) {
      files <- NULL
      if (u_parameters[1,11] == "yes") {
        for (i in 1:7) {
          if (i == 1) {
            files <- c("data/plink_cluster.cluster2",files)
          } else if (i == 2) {
            files <- c("data/plink_pca.eigenvec",files)
          } else if (i == 3) {
            files <- c("data/normalized_plink_pca.txt",files)
          } else if (i == 4) {
            files <- c("data/plink_mds_plot.mds",files)
          } else if (i == 5) {
            files <- c("data/plink_pca.eigenval",files)
          } else if (i == 6) {
            files <- c("data/plink_cluster.cluster3",files)
          } else if (i == 7) {
           files <- c("data/plink_cluster.cluster1",files)
          }
        }
      }else if (u_parameters[1,11] == "no") {
        for (i in 1:4) {
          if (i == 1) {
            files <- c("data/plink_pca.eigenval",files)
          } else if (i == 2) {
            files <- c("data/plink_pca.eigenvec",files)
          } else if (i == 3) {
            files <- c("data/normalized_plink_pca.txt",files)
          } else if (i == 4) {
            files <- c("data/plink_mds_plot.mds",files)
          }
        }
      }
      zip(file,files)
    }
  )

  # FST estimation

  output$selected_clusters <- renderText({
    clus_no1 <- ""
    clus_no2 <- ""
    fst_val <- 0
    for (i in seq(1, nrow(fst_vals), by = 1)) {
      new_cl_pair <- ""
      new_cl_pair <- sprintf("%s-%s", fst_vals[i,1], fst_vals[i,2])
      if (new_cl_pair == input$cls_pairs) {
        clus_no1 <- as.character(fst_vals[i,1])
        clus_no2 <- as.character(fst_vals[i,2])
        fst_val <- as.numeric(fst_vals[i,3])
      }
    }
    if (u_parameters[1,11] == "yes") {
      sprintf("(calculated between clusters %s and %s): %.3f", clus_no1, clus_no2, fst_val)
    } else if (u_parameters[1,11] == "no") {
      sprintf("(calculated between groups %s and %s): %.3f", clus_no1, clus_no2, fst_val)
    }
  })

  fst_data <- reactive({
    file_name <- ""
    for (i in seq(1, nrow(fst_vals), by = 1)) {
      new_cluster_pair <- ""
      new_cluster_pair <- sprintf("%s-%s", fst_vals[i,1], fst_vals[i,2])
      if (new_cluster_pair == input$cls_pairs) {
        file_name <- sprintf("data/results_data.fst_%s_%s.var", fst_vals[i,4], fst_vals[i,5])
      }
    }
    pw_fst_data_matrix <- as.matrix(read.table(file = file_name, header = TRUE))
    if (input$chr_no_fst == "ALL") {
      df <- data.frame(chr_name = as.vector(str_trim(as.character(pw_fst_data_matrix[,1]))), chr_no = as.vector(as.numeric(pw_fst_data_matrix[,2])), var_id = as.vector(as.character(pw_fst_data_matrix[,3])), var_positions = as.vector(as.numeric(pw_fst_data_matrix[,4])), fst_value = as.vector(as.double(pw_fst_data_matrix[,6]))) %>% dplyr::filter(fst_value >= input$min_fst_val)
    } else if (input$chr_no_fst != "ALL") {
      df <- data.frame(chr_name = as.vector(str_trim(as.character(pw_fst_data_matrix[,1]))), chr_no = as.vector(as.numeric(pw_fst_data_matrix[,2])), var_id = as.vector(as.character(pw_fst_data_matrix[,3])), var_positions = as.vector(as.numeric(pw_fst_data_matrix[,4])), fst_value = as.vector(as.double(pw_fst_data_matrix[,6]))) %>% dplyr::filter(fst_value >= input$min_fst_val & chr_name == input$chr_no_fst)
    }
  })

  label_chr_vals <- reactiveValues()
  observe({
    if (input$chr_no_fst == "ALL") {
      df_fst <- fst_data()
      chr_list  <- as.vector(as.character(df_fst[["chr_name"]]))
      label_chr_vals$names <- c(as.vector(as.character(unique(chr_list))))
    } else if (input$chr_no_fst != "ALL") {
      label_chr_vals$names <- NULL
    }
  })

  plot_title <- reactive({
    manh_plot_title <- ""
    clust_no1 <- ""
    clust_no2 <- ""
    for (i in seq(1, nrow(fst_vals), by = 1)) {
      new_clust_pair <- ""
      new_clust_pair <- sprintf("%s-%s", fst_vals[i,1], fst_vals[i,2])
      if (new_clust_pair == input$cls_pairs) {
        clust_no1 <- as.character(fst_vals[i,1])
        clust_no2 <- as.character(fst_vals[i,2])
      }
    }
    if (u_parameters[1,11] == "yes") {
      manh_plot_title <- sprintf("Manhattan plot for Wright's FST values (between clusters %s and %s)", clust_no1, clust_no2)
    } else if (u_parameters[1,11] == "no") {
      manh_plot_title <- sprintf("Manhattan plot for Wright's FST values (between groups %s and %s)", clust_no1, clust_no2)
    }
  })

  fst_x_title_vals <- reactiveValues()
  observe({
    if (input$chr_no_fst == "ALL") {
      fst_x_title_vals$title_str <- sprintf("Chromosomes/Contigs")
    } else if (input$chr_no_fst != "ALL") {
      fst_x_title_vals$title_str <- sprintf("Chromosome/Contig: %s", input$chr_no_fst)
    }
  })

  dataset_input_f <- reactive({
    manhattanr(fst_data(), chr = "chr_no", bp = "var_positions", p = "fst_value", snp = "var_id", annotation1 = "var_positions", annotation2 = "fst_value", logp = FALSE)
  })

  dataset_input_fst <- reactive({
    manhattanly(dataset_input_f(), col = c("#8B008B","#1E90FF","#FF8C00","#20B2AA"),
      point_size = 3, labelChr = label_chr_vals$names, showlegend = TRUE, xlab = fst_x_title_vals$title_str, ylab = "Wright's FST", suggestiveline = FALSE,
      genomewideline = FALSE, title = "Manhattan plot for the Wright's FST values", mode = "markers") %>%
    layout(paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = plot_title(), font = list(family = "sans serif", size = 20, color = "#C71585")),
      font = list(family = "sans serif", size = 14, color = "#4B0082"), margin = 1, hovermode = "closest", hoverdistance = 1) %>%
    config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "fst_chart", width = 1000, height = 600))
  })

  output$view_fst <- renderPlotly({
    validate(
      need(nrow(fst_data()) > 0, "No data exists, please select 0 from the FST value list in 'Minimum FST value' drop-down list.")
    )
    dataset_input_fst()
  })

  output$save_fst <- downloadHandler(
    filename = function() {
      paste("fst_chart", "html", sep = ".")
    },
    content = function(file) {
      htmlwidgets::saveWidget(as_widget(dataset_input_fst()), "fst_t_chart.html")
      file.copy("fst_t_chart.html", file)
    }
  )

  output$save_text_fst <- downloadHandler(
    filename = function() {
      paste0("fst_data", ".zip")
    },
    content = function(file) {
      files <- NULL
      files <- c("data/plink_fst.fst.summary",files)
      file_name <- ""
      for (i in seq(1, nrow(fst_vals), by = 1)) {
        new_cl_pair <- ""
        new_cl_pair <- sprintf("%s-%s", fst_vals[i,1], fst_vals[i,2])
        if (new_cl_pair == input$cls_pairs) {
          clust_no1 <- as.character(fst_vals[i,1])
          clust_no2 <- as.character(fst_vals[i,2])
          file_name <- sprintf("data/plink_fst.%s.%s.fst.var", clust_no1, clust_no2)
        }
      }
      files <- c(file_name,files)
      zip(file,files)
    }
  )

  # Kinship

  ksh_data <- reactive({
    if (input$sort_order == "PLINK Sample ID") {
      if (input$data_type_ksh == "IBS matrix") {
        data_matrix <- ibs_matrix_os
      } else if (input$data_type_ksh == "Relationship matrix") {
        data_matrix <- rel_matrix_os
      } else if (input$data_type_ksh == "KING-robust kinship") {
        data_matrix <- king_matrix_os
      }
    } else if (input$sort_order == "Group/Cluster number") {
      if (input$data_type_ksh == "IBS matrix") {
        data_matrix <- ibs_matrix
      } else if (input$data_type_ksh == "Relationship matrix") {
        data_matrix <- rel_matrix
      } else if (input$data_type_ksh == "KING-robust kinship") {
        data_matrix <- king_matrix
      }
    }
  })

  ksh_lab_col <- reactive({
    if (input$sort_order == "PLINK Sample ID") {
      if (input$data_type_ksh == "IBS matrix") {
        lab_col_text <- colnames(ibs_matrix_os)
      } else if (input$data_type_ksh == "Relationship matrix") {
        lab_col_text <- colnames(rel_matrix_os)
      } else if (input$data_type_ksh == "KING-robust kinship") {
        lab_col_text <- colnames(king_matrix_os)
      }
    } else if (input$sort_order == "Group/Cluster number") {
      if (input$data_type_ksh == "IBS matrix") {
        lab_col_text <- colnames(ibs_matrix)
      } else if (input$data_type_ksh == "Relationship matrix") {
        lab_col_text <- colnames(rel_matrix)
      } else if (input$data_type_ksh == "KING-robust kinship") {
        lab_col_text <- colnames(king_matrix)
      }
    }
  })

  ksh_lab_row <- reactive({
    if (input$sort_order == "PLINK Sample ID") {
      if (input$data_type_ksh == "IBS matrix") {
        labRow_text <- rownames(ibs_matrix_os)
      } else if (input$data_type_ksh == "Relationship matrix") {
        labRow_text <- rownames(rel_matrix_os)
      } else if (input$data_type_ksh == "KING-robust kinship") {
        labRow_text <- rownames(king_matrix_os)
      }
    } else if (input$sort_order == "Group/Cluster number") {
      if (input$data_type_ksh == "IBS matrix") {
        labRow_text <- rownames(ibs_matrix)
      } else if (input$data_type_ksh == "Relationship matrix") {
        labRow_text <- rownames(rel_matrix)
      } else if (input$data_type_ksh == "KING-robust kinship") {
        labRow_text <- rownames(king_matrix)
      }
    }
  })

  plot_title_ksh <- reactive({
    if (input$data_type_ksh == "IBS matrix") {
      ksh_plot_title <- sprintf("IBS matrix (PLINK 1.9)")
    } else if (input$data_type_ksh == "Relationship matrix") {
      ksh_plot_title <- sprintf("Relationship matrix (PLINK 2.0)")
    } else if (input$data_type_ksh == "KING-robust kinship") {
      ksh_plot_title <- sprintf("KING kinship matrix (PLINK 2.0)")
    }
  })

  dataset_input_ksh <- reactive({
    heatmaply(ksh_data(),
      dendrogram = "none",
      xlab = "Samples",
      ylab = "Samples",
      main = "",
      scale = "none",
      grid_gap = 1,
      grid_size = 0.1,
      titleX = TRUE,
      hide_colorbar = FALSE,
      fontsize_row = 5,
      fontsize_col = 5,
      labCol = ksh_lab_col(),
      labRow = ksh_lab_row(),
      heatmap_layers = NULL) %>%
    layout(paper_bgcolor = "#FFE4E1", plot_bgcolor = "#FFFFFF", title = list(text = plot_title_ksh(), font = list(family = "sans serif", size = 20, color = "#C71585")),
      font = list(family = "sans serif", size = 14, color = "#4B0082"), xaxis = list(tickfont = list(family = "sans serif", color = "#800000"), tickangle = 270),
      yaxis = list(tickfont = list(family = "sans serif", color = "#800000")), margin = 1, hovermode = "closest", hoverdistance = 1) %>%
    config(toImageButtonOptions = list(format = u_parameters[1,19], filename = "ksh_chart", width = 1000, height = 1000))
  })

  output$view_ksh <- renderPlotly({
    dataset_input_ksh()
  })

  output$save_ksh <- downloadHandler(
    filename = function() {
      paste("ksh_chart", "html", sep = ".")
    },
    content = function(file) {
      htmlwidgets::saveWidget(as_widget(dataset_input_ksh()), "ksh_t_chart.html")
      file.copy("ksh_t_chart.html", file) 
    }
  )

  output$save_text_ksh <- downloadHandler(
    filename = function() {
      paste0("rel_data", ".zip")
    },
    content = function(file) {
      files <- NULL
      for (i in 1:7) {
        if (i == 1) {
          files <- c("data/plink_distance_ibs.mibs",files)
        } else if (i == 2) {
          files <- c("data/plink_distance_ibs.mibs.id",files)
        } else if (i == 3) {
          files <- c("data/plink_grm.rel",files)
        } else if (i == 4) {
          files <- c("data/plink_grm.rel.id",files)
        } else if (i == 5) {
          files <- c("data/plink_kinship.king",files)
        } else if (i == 6) {
          files <- c("data/plink_kinship.king.id",files)
        } else if (i == 7) {
          files <- c("data/tassel_kinship.txt",files)
        }
      }
      zip(file,files)
    }
  )

}

# Create Shiny app ----
shinyApp(ui = ui, server = server)

