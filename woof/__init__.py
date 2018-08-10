import os
from os.path import join, abspath, dirname, pardir, isfile, exists
import socket
import re
import sys
import yaml
import json

def critical(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

def get_hostname():
    return os.environ.get('HOST') or os.environ.get('HOSTNAME') or socket.gethostname()

WOOF_ROOT = dirname(dirname(abspath(__file__)))
WOOF_RULES = join(WOOF_ROOT, 'woof/rules')

# select the appropriate machine
hpc_dict = {
    'SPARTAN' : {
        'extras' : '/data/cephfs/punim0010/extras',
        'woof_data' : '/data/cephfs/punim0010/extras/woof/data',
        'ref_fasta' : '/data/cephfs/punim0010/local/development/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa'
        },
    'RAIJIN' : {
        'extras' : '/g/data3/gx8/extras',
        'woof_data' : '/g/data3/gx8/extras/woof/data',
        'ref_fasta' : '/g/data3/gx8/local/development/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa'
        },
    'peter' : {
        },
}

hostname = get_hostname()

if re.match(r'spartan*', hostname):
    hostname = 'SPARTAN'
elif re.match(r'^raijin|(r\d\d\d\d$)', hostname):
    hostname = 'RAIJIN'
elif re.match(r'^5180L-133629-M.local$', hostname):
    hostname = 'peter'
else:
    critical(f'ERROR: could not detect location by hostname {hostname}')

hpc_dict = hpc_dict[hostname]
config = {}
config['samples'] = yaml.load(open(join(WOOF_ROOT, 'config/samples.yaml')))
config['bcbio'] = yaml.load(open(join(WOOF_ROOT, 'config/bcbio.yaml')))
config['HPC'] = hpc_dict
config['woof'] = {}

config['woof']['root_dir'] = WOOF_ROOT
config['woof']['rules_dir'] = WOOF_RULES
config['woof']['final_dir'] = join(WOOF_ROOT, 'final') # can change this via command line if needed
config['tools'] = {}

