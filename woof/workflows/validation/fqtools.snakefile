import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"

include: join(WOOF_RULES, "fqtools/fqtools_validate.smk")

vd = config['validate']
fnames = [k for k in vd]

rule all:
    input:
        expand(
            join(config['tools']['fqtools']['validate']['outdir'], '{fname}_valid.txt'),
            fname = fnames
        )
