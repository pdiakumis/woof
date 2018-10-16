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
        'ref_fasta' : '/data/cephfs/punim0010/local/development/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa',
        },
    'RAIJIN' : {
        'extras' : '/g/data3/gx8/extras',
        'woof_data' : '/g/data3/gx8/extras/woof/data',
        'ref_fasta' : '/g/data3/gx8/local/development/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa',
        },
    'peter' : {
        'extras' : '/Users/pdiakumis/extras',
        'woof_data' : '/Users/pdiakumis/extras/woof/data',
        'ref_fasta' : '/Users/pdiakumis/extras/woof/data/genomes/Hsapiens/GRCh37/seq/GRCh37.fa',
        },
    'aws' : {
        'extras' : '/home/ubuntu/extras',
        'woof_data' : '/home/ubuntu/extras/woof/data',
        'ref_fasta' : '/home/ubuntu/extras/woof/data/genomes/Hsapiens/GRCh37/seq/GRCh37.fa'
        },
}

hostname = get_hostname()

if re.match(r'spartan*', hostname):
    hostname = 'SPARTAN'
elif re.match(r'^raijin|(r\d+$)', hostname):
    hostname = 'RAIJIN'
elif re.match(r'^5180L-133629-M.local$', hostname):
    hostname = 'peter'
elif re.match(r'^ip*', hostname):
    hostname = 'aws'
else:
    critical(f'ERROR: could not detect location by hostname {hostname}')

hpc_dict = hpc_dict[hostname]
config = {}
config['HPC'] = hpc_dict # needs to be set up on each machine

config['woof'] = {}
config['woof']['root_dir'] = WOOF_ROOT
config['woof']['rules_dir'] = WOOF_RULES
config['tools'] = {}
