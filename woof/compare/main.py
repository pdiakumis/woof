import os
from os.path import isfile, join, dirname, abspath
import sys
import subprocess as sp
import click
from click import echo
from woof import utils


@click.command()
@click.argument("f1", type=click.Path(exists=True), metavar="<final1>")
@click.argument("f2", type=click.Path(exists=True), metavar="<final2>")
@click.option("-n", "--name", help="Name of the comparison [def: bcbio-comp_<timestamp>]", default=f'bcbio-comp_{utils.timestamp()}')
@click.option("-o", "--outdir", help="Output directory [def: ./woof].", default="woof")
def compare(f1, f2, name, outdir):
    """Compare two bcbio runs <final1> and <final2>"""
    echo(click.style("In compare.main", fg='green'))
    echo(f'f1 is {f1}; f2 is {f2}')

    """
    Step 1: use woofr::bcbio_outputs to generate a TSV output with the following columns:
      - col1: type of VCF file (ensemble-batch, germline-gatk etc.)
      - col2: path to VCF file for <final1>
      - col3: path to VCF file for <final2>

    Step 2: capture output and write to <name>_samples.tsv
    Step 3: copy
    """

    r_cmd = f"Rscript --no-environ -e \"library(woofr); woofr:::merge_bcbio_outputs('{f1}', '{f2}')\""
    cmd = sp.run(r_cmd, stdout=sp.PIPE, encoding='utf-8', shell=True)


    utils.safe_mkdir(outdir)
    with open(join(outdir, f"{name}_samples.tsv"), "w") as out_handle:
        out_handle.write(cmd.stdout)

    echo("This probably means success. Enjoy life!")
