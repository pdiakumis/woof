import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"

include: join(WOOF_RULES, "purple/cobalt.smk")
include: join(WOOF_RULES, "purple/pileup.smk")
include: join(WOOF_RULES, "purple/amber.smk")
include: join(WOOF_RULES, "purple/sv_prep.smk")
include: join(WOOF_RULES, "purple/purple.smk")

batches = config['samples'].keys()

rule all:
    input:
        expand(
            join(config['tools']['purple']['outdir'], '{batch}', 'purple/{tumor_alias}.purple.cnv'),
            zip,
            batch = batches,
            tumor_alias = [alias_from_pheno(config, b, 'tumor') for b in batches]
        )


