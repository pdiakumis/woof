import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES
from itertools import chain

shell.prefix("set -euo pipefail; ")

localrules: all

include: join(WOOF_RULES, "purple/cobalt.smk")
include: join(WOOF_RULES, "purple/pileup.smk")
include: join(WOOF_RULES, "purple/amber.smk")
include: join(WOOF_RULES, "purple/purple.smk")

#batches = config['samples'].keys()
batches = [*config['samples']]
batches_rep = [b for b in batches for i in range(2)] # repeat each element twice
aliases = [aliases_from_batch(config, b) for b in batches]

rule all:
    input:
        expand(
            join(config['tools']['purple']['outdir'], '{batch}', 'cobalt/{tumor_alias}.cobalt'),
            batch = batches,
            tumor_alias = [alias_from_pheno(config, b, 'tumor') for b in batches]),
        expand(
            join(config['tools']['purple']['outdir'], '{batch}', 'amber/{alias}.mpileup'), zip,
            batch = batches_rep,
            alias = list(chain(*aliases))),
        expand(
            join(config['tools']['purple']['outdir'], '{batch}', 'amber/{tumor_alias}.amber.baf'),
            batch = batches,
            tumor_alias = [alias_from_pheno(config, b, 'tumor') for b in batches]
        ),
        expand(
            join(config['tools']['purple']['outdir'], '{batch}', 'purple/{tumor_alias}.purple.cnv'),
            batch = batches,
            tumor_alias = [alias_from_pheno(config, b, 'tumor') for b in batches]
        )


