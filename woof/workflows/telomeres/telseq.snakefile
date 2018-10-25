import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"

include: join(WOOF_RULES, "telseq/telseq.smk")

batches = config['samples'].keys()

rule all:
    input:
        expand(
            join(config['tools']['telseq']['outdir'], '{batch}/{alias}_telseq.tsv'),
            zip,
            batch = [b for b in batches for i in range(2)],
            alias = [alias_from_pheno(config, b, a) for b in batches for a in ['tumor', 'normal']]
        )



