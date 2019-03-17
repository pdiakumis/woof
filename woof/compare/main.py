import os
import sys
import subprocess
import click
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

    """
    Step 0: we want the structure of the `woof/work` to be:
      - wdl_workflow_x.wdl
      - wdl_workflow_y.wdl
      - wdl_tasks/
      - <cromwell_config>.conf
      - <cromwell_opts>.json
      - <cromwell_inputs>.json
    Step 1: use woofr::merge_bcbio_outputs to generate a TSV output with the following columns:
      - col1: type of VCF file (ensemble-batch, germline-gatk etc.)
      - col2: path to VCF file for <final1>
      - col3: path to VCF file for <final2>

    Step 2: capture output and write to samples.tsv
    Step 3: copy
    """

    outdir = utils.adjust_path(outdir)
    f1 = utils.adjust_path(f1)
    f2 = utils.adjust_path(f2)

    utils.safe_mkdir(outdir)
    run.create_cromwell_files(outdir)
    input_samples = create_cromwell_input(f1, f2, os.path.join(outdir, "work"))

    echo(style("This probably means success. Enjoy life!"))


def create_cromwell_input(f1, f2, outdir):

    r_cmd = f"Rscript --no-environ -e \"library(woofr); woofr:::merge_bcbio_outputs('{f1}', '{f2}')\""
    cmd = subprocess.run(r_cmd, stdout=subprocess.PIPE, encoding='utf-8', shell=True)
    fname = os.path.join(outdir, "cromwell_samples.tsv")
    with open(fname, "w") as out_handle:
        out_handle.write(cmd.stdout)

    return fname
