#!/usr/bin/env bash

conda activate woof

vcf_in=$1
dir_name=$(dirname $vcf_in)
vcf_out=${dir_name}/$(basename $vcf_in "pcgr.pass_hg38_unsorted_noalt.vcf.gz")pcgr.pass_clean_hg38_unsorted_noalt.vcf.gz

echo "[$(date)] Start $vcf_in"
gunzip -c ${vcf_in} | sed 's/Clinical /Clinical_/g' | bgzip > ${vcf_out}
echo "[$(date)] Output: $vcf_out"
