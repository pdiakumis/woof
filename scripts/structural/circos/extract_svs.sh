#!/usr/bin/env bash
set -euo pipefail

vcf=$1

bcftools query -f "%CHROM\t%INFO/BPI_START\t%INFO/BPI_END\t%ID\t%INFO/MATEID\t%INFO/SVTYPE\t%FILTER\n" $vcf
