import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: join(WOOF_RULES, "purple/cobalt.smk")

batches = config['samples'].keys()

rule all:
    input:
        expand(
            join(config['tools']['purple']['cobalt']['outdir'], '{batch}', '{tumor_alias}.cobalt'),
            batch = batches,
            tumor_alias = [alias_from_pheno(config, b, 'tumor') for b in batches])

