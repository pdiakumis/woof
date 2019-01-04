import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES
from itertools import chain

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"
include: join(WOOF_RULES, "damest/damest.smk")

batches = [*config['samples']]
batches_rep = [b for b in batches for i in range(2)] # repeat each element twice
aliases = [aliases_from_batch(config, b) for b in batches]

rule all:
    input:
        expand(join(config['tools']['damest']['outdir'], 'bam/{batch}/{alias}_subsample.bam'), zip,
               batch = batches_rep,
               alias = list(chain(*aliases)))
