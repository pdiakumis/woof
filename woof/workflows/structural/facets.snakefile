import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"

include: join(WOOF_RULES, "facets/pileup.smk")
include: join(WOOF_RULES, "facets/facets.smk")

batches = config['samples'].keys()

rule all:
    input:
        expand(
            join(config['tools']['facets']['run']['outdir'], '{batch}/{batch}_cval_{cval}_report.html'),
            batch = batches,
            cval = ["150", "500", "1000"])
