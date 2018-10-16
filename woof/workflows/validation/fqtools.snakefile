import os
from os.path import join, abspath, dirname, pardir, isfile, exists
from itertools import chain
from woof import WOOF_RULES

shell.prefix("set -euo pipefail; ")

localrules: all

include: "../main_settings.py"

include: join(WOOF_RULES, "fqtools/fqtools_validate.smk")
include: join(WOOF_RULES, "vcfvalidator/vcfvalidator_run.smk")

vd = config['validate']
batch = [b for b in vd]
fnames_all = [f for f in vd[batch[0]]]
fastq = [f for f in fnames_all if ftype_from_fname(config, batch[0], f) == "FASTQ"]
bam = [b for b in fnames_all if ftype_from_fname(config, batch[0], b) == "BAM"]
vcf = [v for v in fnames_all if ftype_from_fname(config, batch[0], v) == "VCF"]

rule all:
    input:
        expand(
            join(config['tools']['fqtools']['validate']['outdir'], '{batch}', '{fname}_valid.txt'),
            fname = chain.from_iterable([fastq, bam]),
            batch = batch[0]),
        expand(
            join(config['tools']['vcfvalidator']['outdir'], '{batch}', '{fname}_valid_summary.txt'),
            fname = vcf,
            batch = batch[0])
