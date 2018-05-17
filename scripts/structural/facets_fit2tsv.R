#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(optparse))

# RScript -f <facets fit rds> -m <manta tsv> -o <output prefix>
optlist <- list(
  make_option(c("-f", "--facets"), action = "store", type = "character", default = NULL,
              metavar = "<facets.rds>",
              help = paste0("Input R RDS object containing Facets fit list.",
                            "The output files will have the same name but different suffixes [required]")))

opt <- optparse::parse_args(optparse::OptionParser(option_list = optlist))
# for debugging
opt <- list(
  facets = "/data/cephfs/punim0010/projects/Diakumis_woof/data/out/facets/results/A5_batch1/E131/E131_cval_150_fit.rds"
)
stopifnot(file.exists(opt$facets))

base_nm <- tools:::file_path_sans_ext(opt$facets)

facets_list <- readRDS(opt$facets)

# export purity/ploidy
purity_ploidy <- c(purity = facets_list[["purity"]], ploidy = facets_list[["ploidy"]])
write.table(paste0(base_nm, "_purply.tsv"), as.data.frame(t(purity_ploidy)), row.names = FALSE, sep = "\t", quote = FALSE)

# export cncf
cncf <- facets_list[["cncf"]]
write.table(paste0(base_nm, "_segs.tsv"), cncf, row.names = FALSE, sep = "\t", quote = FALSE)
