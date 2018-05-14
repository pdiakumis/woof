#!/usr/bin/env bash
set -euo pipefail

snakemake -s cnv_report_A5_batch2.snakefile \
          -j 30 \
          -p \
          --cluster-config cluster.json \
          --cluster "sbatch \
          -p {cluster.partition} \
          -n {cluster.n} \
          -t {cluster.time} \
          --mem {cluster.mem} \
          --output {cluster.out} \
          --error {cluster.err} \
          --job-name {cluster.name}"
