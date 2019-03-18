import os
import sys
import subprocess
import click
import json
from click import echo, style
from woof import utils
from woof.cromwell import run


@click.command()
@click.argument("f1", type=click.Path(exists=True), metavar="<final1>")
@click.argument("f2", type=click.Path(exists=True), metavar="<final2>")
@click.option("-o", "--outdir", help="Output directory [def: ./woof].", default="woof")
def compare(f1, f2, outdir):
    """Compare two bcbio runs <final1> and <final2>"""
    echo(style("In compare.main", fg='blue'))
    echo(f'f1 is {f1}; f2 is {f2}')

    outdir = utils.adjust_path(outdir)
    f1 = utils.adjust_path(f1)
    f2 = utils.adjust_path(f2)

    utils.safe_mkdir(outdir)
    work_dir = os.path.join(outdir, "work")
    run.create_cromwell_files(outdir)
    input_samples = create_cromwell_samples(f1, f2, work_dir)
    run.copy_wdl_files(work_dir)
    create_cromwell_input(work_dir)

    echo(style("This probably means success. Enjoy life!", fg='yellow'))


def create_cromwell_samples(f1, f2, outdir):

    r_cmd = f"Rscript --no-environ -e \"library(woofr); woofr:::merge_bcbio_outputs('{f1}', '{f2}')\""
    cmd = subprocess.run(r_cmd, stdout=subprocess.PIPE, encoding='utf-8', shell=True)
    fname = os.path.join(outdir, "cromwell_samples.tsv")
    with open(fname, 'w') as out_handle:
        out_handle.write(cmd.stdout)

    return fname

def create_cromwell_input(outdir):

    d = {}
    d['compare_vcf_files.inputSamplesFile'] = 'cromwell_samples.tsv'
    input_file = os.path.join(outdir, 'cromwell_inputs.json')
    with open(input_file, "w") as out_handle:
        json.dump(d, out_handle)
