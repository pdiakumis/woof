"""Helpful utilities for woof"""

import os
import socket
import re
import sys
import json


def critical(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

def get_hostname():
    return os.environ.get('HOST') or os.environ.get('HOSTNAME') or socket.gethostname()

def get_filesystem():

    hostname = get_hostname()

    if re.match(r'spartan*', hostname):
        fs = 'SPARTAN'
    elif re.match(r'^raijin|(r\d+$)', hostname):
        fs = 'RAIJIN'
    elif re.match(r'^5180L-133629-M.local$', hostname) or re.match(r'^x86_64-apple-darwin13.4.0$', hostname):
        fs = 'PETER'
    elif re.match(r'^ip*', hostname):
        fs = 'AWS'
    else:
        critical(f'ERROR: could not detect location by hostname {hostname}')

    return fs

def safe_mkdir(dname):
    """Make a directory if it doesn't exist, handling concurrent race conditions.
    """
    if not dname:
        return dname
    num_tries = 0
    max_tries = 5
    while not os.path.exists(dname):
        try:
            os.makedirs(dname)
        except OSError:
            if num_tries > max_tries:
                raise
            num_tries += 1
            time.sleep(2)
    return dname


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

