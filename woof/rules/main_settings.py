import os
from os.path import join, abspath, dirname, pardir, isfile, exists
import socket
import re
import sys
import yaml
import json

from snakemake.utils import update_config
from woof import WOOF_ROOT


def critical(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

def get_hostname():
    return os.environ.get('HOST') or os.environ.get('HOSTNAME') or socket.gethostname()

# select the appropriate machine
hpc_dict = {
    'SPARTAN' : {
        'extras' : '/data/cephfs/punim0010/extras',
        'woof_data' : '/data/cephfs/punim0010/extras/woof'
        },
    'RAIJIN' : {
        'extras' : '/g/data3/gx8/extras',
        'woof_data' : '/g/data3/gx8/extras/woof'
        }
}

hostname = get_hostname()

if re.match(r'spartan*', hostname):
    hostname = 'SPARTAN'
elif re.match(r'^raijin|(r\d\d\d\d$)', hostname):
    hostname = 'RAIJIN'
else:
    critical(f'ERROR: could not detect location by hostname {hostname}')

hpc_dict = hpc_dict[hostname]
config = {}
config['samples'] = yaml.load(open(join(WOOF_ROOT, 'config/samples.yaml')))
config['HPC'] = hpc_dict
config['woof'] = {}
config['woof']['root'] = WOOF_ROOT
config['woof']['final'] = join(WOOF_ROOT, "final") # can change this via command line if needed
config['woof']['tool'] = {}
