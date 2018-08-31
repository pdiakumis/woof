require(tidyverse)
require(rock)
require(gtools)

# Take in a VCF with Manta/BPI calls, and output a df with:
# chr1 - pos1 - pos1
# chr2 - pos2 - pos2
# 'color=(r,g,b)'

# Color should be:
# Deletions: Red
# Duplications: Green
# Insertions: Purple
# Inversions: Orange
# BNDs: colour of lower chromosome e.g.:
# (chr1, chr5) -> chr1 colour
# (chr5, chr1) -> chr1 colour
# (chr1, chr1) -> chr1 colour
# (chrY, chr1) -> chr1 colour

# DF <- rock:::read_manta_vcf("../data/purple/BK221-NET1-manta.vcf.gz")
DF <- rock:::read_manta_vcf("../data/purple/BK221-NET1__PRJ180471_BK221-NET1-sv-prioritize-manta-filter.vcf")

df_bnd <- DF %>%
  dplyr::filter(.data$svtype == "BND") %>%
  dplyr::bind_cols(., .[match(.$id, .$mateid), "chrom1"]) %>%
  dplyr::rename(chrom2 = .data$chrom11) %>%
  dplyr::mutate(bndid = substring(.data$id, nchar(.data$id))) %>%
  dplyr::filter(.data$bndid == "1") %>%
  dplyr::select(.data$chrom1, .data$pos1, .data$chrom2, .data$pos2, .data$id, .data$mateid, .data$svtype, .data$filter, .data$n)

stopifnot(rock:::.manta_proper_pairs(df_bnd$id, df_bnd$mateid))

# Non-BNDs
df_other <- DF %>%
  dplyr::filter(.data$svtype != "BND") %>%
  dplyr::mutate(chrom2 = .data$chrom1) %>%
  dplyr::select(.data$chrom1, .data$pos1, .data$chrom2, .data$pos2, .data$id, .data$mateid, .data$svtype, .data$filter, .data$n)

# All together now
sv <- df_other %>%
  dplyr::bind_rows(df_bnd)

min_chrom <- function(chr1, chr2) {
  gtools::mixedsort(c(chr1, chr2))[1]
}

min_chrom_v <- Vectorize(min_chrom)

cols <- c(hs1 = '(153,102,0)', hs2 = '(102,102,0)', hs3 = '(153,153,30)',
          hs4 = '(204,0,0)', hs5 = '(255,0,0)', hs6 = '(255,0,204)',
          hs7 = '(255,204,204)', hs8 = '(255,153,0)', hs9 = '(255,204,0)',
          hs10 = '(255,255,0)', hs11 = '(204,255,0)', hs12 = '(0,255,0)',
          hs13 = '(53,128,0)', hs14 = '(0,0,204)', hs15 = '(102,153,255)',
          hs16 = '(153,204,255)', hs17 = '(0,255,255)', hs18 = '(204,255,255)',
          hs19 = '(153,0,204)', hs20 = '(204,51,255)', hs21 = '(204,153,255)',
          hs22 = '(102,102,102)', hsX = '(153,153,153)', hsY = '(204,204,204)')

links_coloured <- sv %>%
  mutate(chrom1 = paste0("hs", chrom1),
         chrom2 = paste0("hs", chrom2)) %>%
  mutate(min_chrom = min_chrom_v(chrom1, chrom2)) %>%
  mutate(col = case_when(
    svtype == "DEL" ~ '(255,0,0)',
    svtype == "DUP" ~ '(0,255,0)',
    svtype == "INS" ~ '(255,0,255)',
    svtype == "INV" ~ '(255,165,0)',
    svtype == "BND" ~ cols[min_chrom],
    TRUE ~ '0,0,0')) %>%
  mutate(pos1b = pos1,
         pos2b = pos2,
         col = paste0('color=', col)) %>%
  # filter(filter == "PASS") %>%
  select(chrom1, pos1, pos1b, chrom2, pos2, pos2b, col)

links_blue <- sv %>%
  mutate(chrom1 = paste0("hs", chrom1),
         chrom2 = paste0("hs", chrom2)) %>%
  mutate(min_chrom = min_chrom_v(chrom1, chrom2)) %>%
  mutate(col = case_when(
    svtype == "DEL" ~ 'red',
    svtype == "DUP" ~ 'green',
    svtype == "INS" ~ 'vdyellow',
    svtype == "INV" ~ 'black',
    svtype == "BND" ~ 'blue',
    TRUE ~ 'purple')) %>%
  mutate(pos1b = pos1,
         pos2b = pos2,
         col = paste0('color=', col)) %>%
  # filter(filter == "PASS") %>%
  select(chrom1, pos1, pos1b, chrom2, pos2, pos2b, col) %>%
  arrange(chrom1, chrom2, pos1, pos2)


readr::write_tsv(links_blue, "../data/purple/circos/BK221_NET1_tumor.link2.circos", col_names = FALSE)
# readr::write_tsv(links_coloured, "../data/purple/circos/BK221_NET1_tumor.link2.circos", col_names = FALSE)
