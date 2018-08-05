import os
from os.path import join, abspath, dirname, pardir, isfile, exists

from woof import WOOF_ROOT, config
from woof.utils import pheno, alias_from_pheno, bam_from_pheno

