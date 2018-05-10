suppressPackageStartupMessages(library(rmarkdown))
suppressPackageStartupMessages(library(optparse))

option_list <- list(
  make_option(c("-r", "--report"), action = "store", type = "character", default = NULL,
              help = "RMarkdown report to render"),
  make_option(c("-s", "--samplename"), action = "store", type = "character", default = NULL,
              help = "Sample name"),
  make_option(c("-c", "--cval"), action = "store", type = "double", default = 150,
              help = "Critical value [%default]"),
  make_option(c("-o", "--outdir"), action = "store", type = "character", default = NULL,
              help = "Output directory for plots and objects")
)

opt <- parse_args(OptionParser(option_list = option_list))
stopifnot(!is.null(opt$report), !is.null(opt$samplename), !is.null(opt$outdir))

rmarkdown::render(opt$report,
                  params = list(samplename = opt$samplename, cval = opt$cval, outdir = opt$outdir),
                  output_file = paste0("facets_report_", opt$samplename, "_cval_", opt$cval, ".html"))

