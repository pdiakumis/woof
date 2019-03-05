#!/usr/bin/env bash

cromwell run \
  -i inputs.json \
  -Dconfig.file=conf/cromwell.conf \
  -DLOG_LEVEL=ERROR \
  -DLOG_LEVEL=WARN \
  --metadata-output meta.json \
  --options options.json \
  compare_vcf_files.wdl
