import os
import yaml
from os.path import join, abspath, dirname, pardir, isfile, exists
from woof import WOOF_RULES, WOOF_ROOT
from itertools import chain

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"
include: join(WOOF_RULES, "damest/damest.smk")

config['samples'] = yaml.load(open(join(WOOF_ROOT, 'config/samples_cup.yaml')))

batches = [*config['samples']]
batches_rep = [b for b in batches for i in range(2)] # repeat each element twice
aliases = [aliases_from_batch(config, b) for b in batches]

rule all:
    input:
        expand(join(config['tools']['damest']['outdir'], 'results/{batch}/{alias}_tot_damage.tsv'), zip,
                batch = batches_rep,
                alias = list(chain(*aliases)))

