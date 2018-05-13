require(OmicCircos)
require(dplyr)

#---- Function ----
gen_link_dat <- function(svdat, keep_deletions = TRUE, valid_chroms = c(1:22, "X", "Y")) {

  # keep only PASS
  svdat <- svdat[svdat$FILTER == "PASS", ]
  ids <- svdat$ID
  pairs1 <- as.list(rep(NA, length(ids)))
  pairs2 <- as.list(rep(NA, length(ids)))
  i <- 0
  for (id in ids) {
    i <- i + 1
    info <- strsplit(svdat$INFO[i], ";")[[1]] # list of char vec --> take vec

    info_split <- lapply(info, function(x) strsplit(x, "=")[[1]])
    info_dict <- sapply(info_split, function(x) unlist(tail(x, n = 1))) # take last field of each element
    names(info_dict) <- sapply(info_split, function(x) x[1])

    gene <- paste0("Gene", i)
    pos <- svdat$POS[i]
    chrom <- svdat$CHROM[i]


    manta_type <- substr(id, 1, 8)

    if (manta_type == "MantaDEL" & keep_deletions) {
      len <- as.numeric(info_dict["SVLEN"]) * -1
      pairs2[[i]] = c(chrom, pos, gene, chrom, pos + len, gene, "del")

    } else if (manta_type == "MantaBND") {

      mate <- match(info_dict["MATEID"], ids)
      if (mate > i) {
        info <- strsplit(svdat$INFO[mate], ";")[[1]]
        info_split <- lapply(info, function(x) strsplit(x, "=")[[1]])
        info_dict <- sapply(info_split, function(x) unlist(tail(x, n = 1)))
        names(info_dict) <- sapply(info_split, function(x) x[1])

        gene2 <- paste0("Gene", mate)
        pos2 <- svdat$POS[mate]
        chrom2 <- svdat$CHROM[mate]

        pairs1[[i]] <- c(chrom, pos, gene, chrom2, pos2, gene2)
      }

    } else if (manta_type == "MantaINV") {
      len <- as.numeric(info_dict["SVLEN"])
      pairs2[[i]] <- c(chrom, pos, gene, chrom, pos + len, gene, "inv")

    } else if (manta_type == "MantaINS") {
      len <- as.numeric(info_dict["SVLEN"])
      pairs2[[i]] <- c(chrom, pos, gene, chrom, pos + len, gene, "ins")

    } else if (manta_type == "MantaDUP") {
      len <- as.numeric(info_dict["SVLEN"])
      pairs2[[i]] <- c(chrom, pos, gene, chrom, pos + len, gene, "dup")

    }
  }

  pairs1 <- pairs1[!is.na(pairs1)]
  pairs2 <- pairs2[!is.na(pairs2)]

  pairsdf <- data.frame(chr1 = rep(NA, length(pairs1)), po1 = NA, gene1 = NA, chr2 = NA, po2 = NA, gene2 = NA)
  for (i in 1:length(pairs1)) {
    for (j in 1:6) {
      pairsdf[i, j] <- pairs1[[i]][j]
    }
  }

  samechrompairsdf <- data.frame(chr1 = rep(NA, length(pairs2)), po1 = NA, gene1 = NA, chr2 = NA, po2 = NA, gene2 = NA, type = NA)
  for (i in 1:length(pairs2)) {
    for (j in 1:7) {
      samechrompairsdf[i, j] <- pairs2[[i]][j]
    }
  }

  # Keep only valid chromosomes
  pairsdf <- pairsdf[pairsdf$chr1 %in% valid_chroms &
                       pairsdf$chr2 %in% valid_chroms, ]
  samechrompairsdf <- samechrompairsdf[samechrompairsdf$chr1 %in% valid_chroms &
                                         samechrompairsdf$chr2 %in% valid_chroms, ]

  return(list(pairsdf, samechrompairsdf))
}


#---- Chromosome data ----
data("UCSC.hg19.chr", package = 'OmicCircos')
ucsc_chr <- UCSC.hg19.chr %>%
  mutate_if(is.factor, as.character) %>%
  mutate(chrom = sub("chr", "", chrom))

rm(UCSC.hg19.chr)

seg_name <- unique(ucsc_chr$chrom)
seg_num <- length(seg_name)

# Prepare angles + colors
db <- OmicCircos::segAnglePo(seg.dat = ucsc_chr, seg = seg_name)
colors <- rainbow(seg_num, alpha = 0.5)

#---- Manta ----
mantaf <- "/Users/pdiakumis/Desktop/projects/umccr/A5/manta/E019-sv-prioritize-manta.vcf.gz"
svdat <- readr::read_tsv(mantaf, comment = "#", col_types = "ciccccccccc",
                         col_names = c("CHROM", "POS", "ID", "REF", "ALT",
                                       "QUAL", "FILTER", "INFO", "FORMAT",
                                       "normal", "tumor"))

linkdat <- gen_link_dat(svdat)
linkdat_breakends <- linkdat[[1]]
linkdat_samechrom <- linkdat[[2]]

#---- Facets ----
facets_fit <- "~/Desktop/projects/umccr/cnv-callers/facets/reports/colo829/out/cval_150_fit.rds"
cnv <- readr::read_rds(facets_fit)$cncf
extra_df <- tibble::tribble( ~chrom, ~start, ~end, ~tcn.em,
                             #-----|-------|-----|--------|
                             1,      0,    0,       0,
                             1,      0,    0,       4)
mapdat <- cnv %>%
  dplyr::select(chrom, start, end, tcn.em) %>%
  dplyr::bind_rows(extra_df) %>%
  dplyr::rename(chr = chrom,
         CN = tcn.em)

mapdat <- mapdat %>%
  dplyr::mutate(
    col = dplyr::case_when(
      CN == 0 ~ "blue",
      CN == 1 ~ "blue",
      CN == 2 ~ "black",
      CN == 3 ~ "red",
      CN > 3  ~ "red",
      TRUE    ~ "green"))

#---- Circos Plot ----

pdf("~/Desktop/tmp/circos2.pdf", width = 7, height = 7)
par(mar = c(2, 2, 2, 2))
plot(c(1, 800), c(1, 800), type = "n", axes = FALSE, xlab = "", ylab = "", main = "", cex = 2)
circos(R = 400, cir = db, type = "chr", col = colors, print.chr.lab = TRUE, W = 4, scale = TRUE, cex = 3)
circos(R = 260, cir = db, W = 120, mapping = mapdat, col.v = 4, type = "arc", B = TRUE, cutoff = 2, lwd = 4, col = mapdat$col, scale = TRUE, cex = 10)
circos(R = 260, cir = db, W = 40, mapping = linkdat_breakends, type = "link", lwd = 2, col = "grey")
circos(R = 260, cir = db, W = 20, mapping = linkdat_samechrom, type = "link2", lwd = 1, col = c("darkblue", "green")[ifelse(linkdat_samechrom$type == "del", 1, 2)])
dev.off()
