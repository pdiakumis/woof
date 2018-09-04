#!/usr/bin/env bash
set -euo pipefail

snakemake -s ../woof/workflows/structural/purple.snakefile \
          -j 20 \
          -p \
          --cluster-config ../config/spartan_settings.json \
          --cluster \
          "sbatch \
          -p vccc \
          --ntasks {cluster.ntasks} \
          --cpus-per-task {threads} \
          --time {cluster.time} \
          --mem {cluster.mem} \
          --output {cluster.out} \
          --error {cluster.err} \
          --job-name {cluster.name}"

