#!/usr/bin/env bash

set -euo pipefail


(
echo "Starting process 1"
sample="NET-A18"
data_dir="telomerecat/telbams/${sample}"
bams="${data_dir}/PRJ180614_10-116-A18-WB191-N-ready_telbam.bam ${data_dir}/PRJ180615_10-116-A18-WB-T-ready_telbam.bam"
log="${sample}_telomerecat_telbam2length.log"
echo "[$(date)] start telomerecat telbam2length" >> $log

telomerecat telbam2length \
    -p 16 \
    -v 1 \
    --output telomerecat/results/${sample}.csv \
    ${bams} &>> $log

echo "[$(date)] end telomerecat telbam2length" >> $log
echo "Ending process 1"
) &> log1.txt &

(
echo "Starting process 2"
sample="IPMN3152"
data_dir="telomerecat/telbams/${sample}"
bams="${data_dir}/PRJ170095_IPMN3152_T-ready_telbam.bam ${data_dir}/PRJ170096_IPMN3152_N-ready_telbam.bam"
log="${sample}_telomerecat_telbam2length.log"
echo "[$(date)] start telomerecat telbam2length" >> $log

telomerecat telbam2length \
    -p 16 \
    -v 1 \
    --output telomerecat/results/${sample}.csv \
    ${bams} &>> $log

echo "[$(date)] end telomerecat telbam2length" >> $log
echo "Ending process 2"
) &> log2.txt &
