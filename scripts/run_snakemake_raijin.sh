#!/usr/bin/env bash
set -euo pipefail

snakemake -s ../woof/workflows/structural/purple.snakefile \
          -j 20 \
          -p \
          --cluster-config ../config/raijin_settings.json \
          --cluster \
          "qsub \
          -P gx8 \
          -q normalsp \
          -N {cluster.name} \
          -l wd \
          -l \
          walltime={cluster.time},\
          ncpus={threads},\
          mem={cluster.mem},\
          jobfs={cluster.jobfs}"

