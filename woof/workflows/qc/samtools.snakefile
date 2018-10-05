import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES
from itertools import chain

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"
include: join(WOOF_RULES, "samtools/samtools_idxstats.smk")

batches = [*config['samples']]
batches_rep = [b for b in batches for i in range(2)] # repeat each element twice
aliases = [aliases_from_batch(config, b) for b in batches]


rule all:
    input:
        expand(
            join(config['tools']['samtools']['idxstats']['outdir'], '{batch}/{alias}_idxstats.txt'), zip,
            batch = batches_rep,
            alias = list(chain(*aliases)))
