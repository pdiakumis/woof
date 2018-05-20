#!/usr/bin/env bash
set -euo pipefail

snakemake -s Snakefile \
          -j 40 \
          -p \
          --cluster-config spartan.json \
          --cluster "sbatch \
          -p {cluster.partition} \
          -n {cluster.n} \
          -t {cluster.time} \
          --mem {cluster.mem} \
          --output {cluster.out} \
          --error {cluster.err} \
          --job-name {cluster.name}"
