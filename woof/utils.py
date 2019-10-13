"""
Helpful utilities for woof.
Most have been copied/modified from bcbio or ngs_utils.
"""

import os
import socket
import re
import sys
import json
import datetime
from distutils.dir_util import copy_tree
import contextlib

def setup_woof_dirs(d, sample):
    """Create woof/final and woof/work/<sample> dirs"""
    d = adjust_path(d)
    work_dir = os.path.join(d, "work", sample)
    final_dir = os.path.join(d, "final")
    safe_mkdir(work_dir)
    safe_mkdir(final_dir)

    return (work_dir, final_dir)


def critical(msg):
    sys.stderr.write(msg + '\n')
    sys.exit(1)

def get_hostname():
    return os.environ.get('HOSTNAME') or os.environ.get('HOST') or socket.gethostname()

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

def find_package_files(dirpath, package, skip_exts=None):
    paths = []
    for (path, dirs, fnames) in os.walk(os.path.join(package, dirpath)):
        for fname in fnames:
            if skip_exts and any(fname.endswith(ext) for ext in skip_exts):
                continue
            fpath = os.path.join(path, fname)
            paths.append(os.path.relpath(fpath, package))
    return paths

def timestamp():
    return datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

def file_exists(fname):
    """Check if a file exists and is non-empty.
    """
    try:
        return fname and os.path.exists(fname) and os.path.getsize(fname) > 0
    except OSError:
        return False

def adjust_path(path):
    if path is None: return None

    path = remove_quotes(path)
    if path is None: return None

    path = expanduser(path)
    if path is None: return None

    path = os.path.abspath(path)
    if path is None: return None

    return path

def expanduser(path):
    """
    Expand ~ and ~user constructs.
    If user or $HOME is unknown, do nothing.
    """
    if path[:1] != '~':
        return path
    i, n = 1, len(path)
    while i < n and path[i] not in '/\\':
        i = i + 1

    if 'HOME' in os.environ:
        userhome = os.environ['HOME']
    elif 'USERPROFILE' in os.environ:
        userhome = os.environ['USERPROFILE']
    elif not 'HOMEPATH' in os.environ:
        return path
    else:
        try:
            drive = os.environ['HOMEDRIVE']
        except KeyError:
            drive = ''
        userhome = os.path.join(drive, os.environ['HOMEPATH'])

    if i != 1:  # ~user
        userhome = os.path.join(os.path.dirname(userhome), path[1:i])

    return userhome + path[i:]

def remove_quotes(s):
    if s and s[0] in ['"', "'"]:
        s = s[1:]
    if s and s[-1] in ['"', "'"]:
        s = s[:-1]
    return s

def copy_recursive(src, dest):
    """Copy directory recursively
    From https://stackoverflow.com/a/31039095/2169986
    """
    copy_tree(src, dest)



@contextlib.contextmanager
def chdir(new_dir):
    """
    Context manager to temporarily change to a new directory.
    On busy filesystems can have issues accessing main directory, so allow retries.
    """
    num_tries = 0
    max_tries = 5
    cur_dir = None
    while cur_dir is None:
        try:
            cur_dir = os.getcwd()
        except OSError:
            if num_tries > max_tries:
                raise
            num_tries += 1
            time.sleep(2)
    safe_mkdir(new_dir)
    os.chdir(new_dir)
    try:
        yield
    finally:
        os.chdir(cur_dir)

# select the appropriate machine
# hpc_dict = {
#     'SPARTAN' : {
#         'extras' : '/data/cephfs/punim0010/extras',
#         'woof_data' : '/data/cephfs/punim0010/extras/woof/data',
#         'ref_fasta' : '/data/cephfs/punim0010/local/development/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa',
#         },
#     'RAIJIN' : {
#         'extras' : '/g/data3/gx8/extras',
#         'woof_data' : '/g/data3/gx8/extras/woof/data',
#         'ref_fasta' : '/g/data3/gx8/local/development/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa',
#         },
#     'peter' : {
#         'extras' : '/Users/pdiakumis/extras',
#         'woof_data' : '/Users/pdiakumis/extras/woof/data',
#         'ref_fasta' : '/Users/pdiakumis/extras/woof/data/genomes/Hsapiens/GRCh37/seq/GRCh37.fa',
#         },
#     'aws' : {
#         'extras' : '/home/ubuntu/extras',
#         'woof_data' : '/home/ubuntu/extras/woof/data',
#         'ref_fasta' : '/home/ubuntu/extras/woof/data/genomes/Hsapiens/GRCh37/seq/GRCh37.fa'
#         },
# }

