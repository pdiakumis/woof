import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: join(WOOF_RULES, "facets/pileup.smk")
include: join(WOOF_RULES, "facets/facets.smk")

rule all:
    input:
        expand(
            join(config['tools']['facets']['run']['outdir'], '{batch}/{batch}_cval_{cval}_report.html'),
            batch = config['samples'].keys(),
            cval = "150")
