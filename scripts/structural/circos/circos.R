#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(OmicCircos))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(optparse))

# RScript -f <facets fit rds> -m <manta tsv> -o <output prefix>
optlist <- list(
  make_option(c("-f", "--facets"), action = "store", type = "character", default = NULL,
              metavar = "<facets.rds>",
              help = "Input R RDS object containing Facets fit list [required]"),
  make_option(c("-m", "--manta"), action = "store", type = "character", default = NULL,
              metavar = "<manta_svs.tsv>",
              help = "Input TSV file containing Manta SV information [required]"),
  make_option(c("-o", "--output"), action = "store", type = "character", default = NULL,
              metavar = "<output_prefix>",
              help = "Output file prefix [required]"))

opt <- optparse::parse_args(optparse::OptionParser(option_list = optlist))
stopifnot(file.exists(opt$manta), file.exists(opt$facets), !is.null(opt$output))


read_svs <- function(fname) {

  DF <- read.table(file = fname, na.strings = c("."), header = FALSE,
                   col.names = c("chrom", "bpi_start", "bpi_end", "id", "mateid", "svtype", "filter"),
                   colClasses = c("character", "integer")[c(1, 2, 2, 1, 1, 1, 1)]) %>%
    dplyr::mutate(rowid = 1:nrow(.),
                  chrom1 = chrom,
                  start1 = bpi_start,
                  end1 = bpi_start,
                  END = bpi_end) %>%
    dplyr::select(rowid, chrom1, start1, end1, END, filter, id, mateid, svtype)

  # BNDs
  # just keep first BND mates (i.e. discard duplicated information)
  # see <https://github.com/Illumina/manta/blob/master/docs/developerGuide/ID.md>
  df_bnd <- DF %>%
    dplyr::filter(svtype == "BND") %>%
    dplyr::bind_cols(., .[match(.$id, .$mateid), c("chrom1", "start1")]) %>%
    dplyr::rename(chrom2 = chrom11, start2 = start11) %>%
    dplyr::mutate(end2 = start2,
                  bndid = substring(id, nchar(id))) %>%
    dplyr::filter(bndid == "1")

  # Other
  df_other <- DF %>%
    dplyr::filter(svtype != "BND") %>%
    dplyr::mutate(chrom2 = chrom1, start2 = END, end2 = END)

  # All together now
  svs <- df_other %>%
    dplyr::bind_rows(df_bnd) %>%
    dplyr::select(rowid, chrom1:end1, chrom2:end2, svtype, id, filter) %>%
    dplyr::arrange(rowid)

  return(svs)
}

#---- Chromosome data ----#
data("UCSC.hg19.chr", package = 'OmicCircos')
ucsc_chr <- UCSC.hg19.chr %>%
  dplyr::mutate_if(is.factor, as.character) %>%
  dplyr::mutate(chrom = sub("chr", "", chrom))

rm(UCSC.hg19.chr)

seg_name <- unique(ucsc_chr$chrom)
seg_num <- length(seg_name)

# Prepare angles + colors
db <- OmicCircos::segAnglePo(seg.dat = ucsc_chr, seg = seg_name)
chr_colors <- rainbow(seg_num, alpha = 0.5)

#---- Manta ----#
svs <- read_svs(opt$manta) %>%
  dplyr::filter(filter == "PASS") %>%
  dplyr::mutate(varnum = paste0("var", rowid),
                varnum2 = varnum) %>%
  dplyr::select(chrom1, start1, varnum,
                chrom2, start2, varnum2, svtype) %>%
  dplyr::mutate(col = dplyr::case_when(
    svtype == "DEL" ~ "red",
    svtype == "DUP" ~ "green",
    svtype == "INS" ~ "purple",
    svtype == "INV" ~ "orange",
    TRUE    ~ "pink"))

svs_bnd <- svs %>% filter(svtype == "BND")
svs_other <- svs %>% filter(svtype != "BND")

#---- Facets ----#
facets_fname <- opt$facets
facets_cnv <- readRDS(facets_fname)$cncf %>%
  dplyr::select(chrom, start, end, tcn.em) %>%
  dplyr::rename(chr = chrom,
                CN = tcn.em) %>%
  dplyr::mutate(
    col = dplyr::case_when(
      CN == 0 ~ "red",
      CN == 1 ~ "red",
      CN == 2 ~ "black",
      CN >= 3 ~ "green",
      TRUE    ~ "orange"))

#---- Circos Plot ----

options(warn = -1)
pdf(paste0(opt$output, ".pdf"), width = 7, height = 7)
par(mar = c(.5, .5, .5, .5))
plot(c(1, 800), c(1, 800), type = "n", axes = FALSE, xlab = "", ylab = "", main = "")

circos(R = 400, cir = db, type = "chr", col = chr_colors, print.chr.lab = TRUE, W = 4)
circos(R = 260, cir = db, type = "arc", W = 120, mapping = facets_cnv, col.v = 4, B = TRUE, lwd = 5, col = facets_cnv$col, scale = FALSE)

# turn off warnings because in their code they take max/min of character matrix...
circos(R = 260, cir = db, type = "link", W = 40, mapping = svs_bnd, lwd = 2, col = "grey")
circos(R = 260, cir = db, type = "link2", W = 20, mapping = svs_other, lwd = 1, col = svs_other$col)
dev.off()
