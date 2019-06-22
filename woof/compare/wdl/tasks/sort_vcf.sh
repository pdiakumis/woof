#!/usr/bin/env bash

vcf_in=$1
dir_name=$(dirname $vcf_in)
vcf_out=${dir_name}/$(basename $vcf_in "hg38_unsorted_noalt.vcf.gz")hg38_final.vcf.gz

echo "[$(date)] $(basename $vcf_in)"
bcftools sort -Oz -o $vcf_out $vcf_in && tabix -p vcf $vcf_out
echo "[$(date)] end...."
sleep 5
echo "________________________"
