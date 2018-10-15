import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"

include: join(WOOF_RULES, "fqtools/fqtools_validate.smk")

vd = config['validate']
batch = [b for b in vd]
fnames = [f for f in vd[batch[0]]]

rule all:
    input:
        expand(
            join(config['tools']['fqtools']['validate']['outdir'], '{batch}', '{fname}_valid.txt'),
            fname = fnames,
            batch = batch
        )
