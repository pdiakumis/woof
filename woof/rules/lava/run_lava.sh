#!/usr/bin/env bash

set -euo pipefail

export PATH=/home/pdiakumis/my_apps/lava:$PATH

#REF=/data/cephfs/punim0010/local/stable/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
REF=/data/cephfs/punim0010/extras/vlad/bcbio/genomes/Hsapiens/hg19/seq/hg19.fa
SNP=../../data/Affymetrix_6_SNPs.txt
OUT_DIR=../../data/out
REF_DICT=${OUT_DIR}/ref_dict
SNP_DICT=${OUT_DIR}/snp_dict
FASTQ=../../data/SRR622461.filt.fastq


# Step 1
echo "[$(date)] start lava dict"
lava dict $REF $SNP $REF_DICT $SNP_DICT
echo "[$(date)] end lava dict"

# Step 2
echo "[$(date)] start lava lava"
lava lava $REF_DICT $SNP_DICT $FASTQ ${REF}.chrlens ${OUT_DIR}/lava_results.txt
echo "[$(date)] end lava lava"

