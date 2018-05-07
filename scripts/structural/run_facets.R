suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(devtools))
suppressPackageStartupMessages(library(facets))
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(rr))
set.seed(13)

# RScript -s <sample name> -f <snp file> -c <cval> -o <output dir>
option_list <- list(
  make_option(c("-s", "--samplename"), action = "store", type = "character", default = NULL,
              help = "Sample name"),
  make_option(c("-f", "--snpfile"), action = "store", type = "character", default = NULL,
              help = "Path to file containing SNP allele counts"),
  make_option(c("-c", "--cval"), action = "store", type = "double", default = 150,
              help = "Critical value [%default]"),
  make_option(c("-o", "--outdir"), action = "store", type = "character", default = NULL,
              help = "Output directory for plots and objects")
)

opt <- parse_args(OptionParser(option_list = option_list))

opt <- list(samplename = "HCC2218",
            snpfile = "/data/cephfs/punim0010/projects/Diakumis_woof/data/out/facets/coverage/HCC2218/HCC2218_cov.csv.gz",
            cval = 150,
            outdir = "/data/cephfs/punim0010/projects/Diakumis_woof/data/out/facets/results/HCC2218")

stopifnot(!is.null(opt$snpfile),
          !is.null(opt$samplename),
          is.numeric(opt$cval),
          !is.null(opt$outdir))


cat(stamp(), "Starting Facets analysis\n")
cat(stamp(), paste0("Arguments specified:\n",
                    "\tsnpfile: ", opt$snpfile, "\n",
                    "\tsamplename: ", opt$samplename, "\n",
                    "\tcval: ", opt$cval, "\n",
                    "\toutdir: ", opt$outdir, "\n"))

if (!dir.exists(opt$outdir)) {
  dir.create(opt$outdir, recursive = TRUE)
}

# Read in SNP allele count file and prepare for next step
cat(stamp(), "Reading in", opt$snpfile, "with `readSnpMatrix`\n")
cov_mat <- readSnpMatrix(opt$snpfile)
cat(stamp(), "Total of", nrow(cov_mat), "rows in matrix\n")

cat(stamp(), "Pre-processing matrix with `preProcSample`\n")
pre_proc <- preProcSample(cov_mat, gbuild = "hg19")

# Process SNP matrix for given cval
# Declare a change if maximal statistic is greater than pre-determined critical value `cval`
# Lower `cval` leads to higher sensitivity for small changes
cat(stamp(), "Processing matrix with `procSample`\n")
proc <- procSample(pre_proc, cval = opt$cval)

# Call allele-specific copy number and associated cellular fraction, estimate
# tumor purity and ploidy (most time-consuming step):
cat(stamp(), "Running `emcncf`\n")
fit <- emcncf(proc)
cat(stamp(), "Purity is:", fit$purity, "\n")
cat(stamp(), "Ploidy is:", fit$ploidy, "\n")

# The segmentation result and the EM fit output is shown below, where:
#   - cf, tcn, lcn: initial estimates of cellular fraction, total + minor copy
#     number estimates
#   - cf.em, tcn.em, lcn.em are the estimates by the mixture model optimized
#     using the EM-algorithm

# Plots
cnv_plotname <- file.path(opt$outdir, "cnv")
spider_plotname <- file.path(opt$outdir, "spider")


cat(stamp(), "Plotting CNVs in pdf + png format\n")
pdf(paste0(cnv_plotname, ".pdf"))
plotSample(x = proc, emfit = fit)
dev.off()

# png can't work on linux; trying bitmap via https://biostar.usegalaxy.org/p/9170/
# Quality is crap so just skipping for now
# bitmap(paste0(cnv_plotname, ".png"))
# plotSample(x = proc, emfit = fit)
# dev.off()

# png(paste0(cnv_plotname, ".png"))
# plotSample(x = proc, emfit = fit)
# dev.off()

cat(stamp(), "Plotting Spider in pdf + png format\n")
pdf(paste0(spider_plotname, ".pdf"))
logRlogORspider(proc$out, proc$dipLogR)
dev.off()

# Save Objects
cat(stamp(), "Saving `fit` object\n")
saveRDS(fit, file.path(opt$outdir, paste0(opt$samplename, "_cval_", opt$cval, "_fit.rds")))

cat(stamp(), "Finished Facets analysis\n")
devtools::session_info()
