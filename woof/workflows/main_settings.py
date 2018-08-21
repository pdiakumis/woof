import os
from os.path import join, abspath, dirname, pardir, isfile, exists
import yaml
from woof import WOOF_ROOT, config
from woof.utils import pheno, alias_from_pheno, bam_from_pheno, aliases_from_batch, bam_from_alias


config['woof']['final_dir'] = join(WOOF_ROOT, 'final')
config['samples'] = yaml.load(open(join(WOOF_ROOT, 'config/samples.yaml')))
config['bcbio'] = yaml.load(open(join(WOOF_ROOT, 'config/bcbio.yaml')))
