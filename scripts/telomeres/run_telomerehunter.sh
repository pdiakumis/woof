#!/usr/bin/env bash

set -euo pipefail

sample="NET-A18"
data_dir="../data/${sample}"
out_dir="telomerehunter/${sample}"
bam_tumor="PRJ180615_10-116-A18-WB-T-ready.bam"
bam_normal="PRJ180614_10-116-A18-WB191-N-ready.bam"
log="${sample}_telomerehunter.log"

echo "[$(date)] start telomerehunter" >> $log

telomerehunter \
    -ibt ${data_dir}/${bam_tumor} \
    -ibc ${data_dir}/${bam_normal} \
    -o ${out_dir} \
    --pid ${sample} \
    --parallel \
    --plotFileFormat all &>> $log

echo "[$(date)] end telomerehunter" >> $log
