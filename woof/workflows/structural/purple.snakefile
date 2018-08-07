import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES
from itertools import chain

shell.prefix("set -euo pipefail; ")

localrules: all

include: join(WOOF_RULES, "samtools/samtools_idxstats.smk")
include: join(WOOF_RULES, "purple/cobalt.smk")
include: join(WOOF_RULES, "purple/pileup.smk")

#batches = config['samples'].keys()
batches = [*config['samples']]
batches_rep = [b for b in batches for i in range(2)] # repeat each element twice
aliases = [aliases_from_batch(config, b) for b in batches]

rule all:
    input:
        expand(
            join(config['tools']['purple']['cobalt']['outdir'], '{batch}', '{tumor_alias}.cobalt'),
            batch = batches,
            tumor_alias = [alias_from_pheno(config, b, 'tumor') for b in batches]),
        expand(
            join(config['tools']['purple']['amber_pileup']['outdir'], '{batch}/{alias}.mpileup'), zip,
            batch = batches_rep,
            alias = list(chain(*aliases))),
        expand(
            join(config['tools']['samtools']['idxstats']['outdir'], '{batch}/{alias}_idxstats.txt'), zip,
            batch = batches_rep,
            alias = list(chain(*aliases)))


