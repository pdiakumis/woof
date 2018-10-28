#!/usr/bin/env bash

set -euo pipefail

data_dir="../data/NET-A18"
bam="PRJ180614_10-116-A18-WB191-N-ready.bam"
log="${bam}_telomerecat_bam2telbam.log"

echo "[$(date)] start telomerecat bam2telbam" >> $log

telomerecat bam2telbam \
    -p 16 \
    -v 1 \
    ${data_dir}/${bam} &>> $log

echo "[$(date)] end telomerecat bam2telbam" >> $log
