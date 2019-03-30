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

    outdir = utils.adjust_path(outdir)
    f1 = utils.adjust_path(f1)
    f2 = utils.adjust_path(f2)
    echo(f'f1 is {f1}; f2 is {f2}')

    work_dir = os.path.join(outdir, "work")
    final_dir = os.path.join(outdir, "final")
    utils.safe_mkdir(work_dir)
    utils.safe_mkdir(final_dir)


    input_file = create_cromwell_input(f1, f2, work_dir, final_dir)
    wdl_workflow = os.path.join(work_dir, "wdl", "compare_vcf_files.wdl")
    run.run_cromwell(outdir, input_file, wdl_workflow)

    echo(click.style(f"[{utils.timestamp()}] woof end", fg='yellow'))


def create_cromwell_input(f1, f2, outdir, final_dir):

    def _create_cromwell_samples(f1, f2, outdir):
        r_cmd = f"Rscript --no-environ -e \"library(woofr); woofr:::merge_bcbio_outputs('{f1}', '{f2}')\""
        cmd = subprocess.run(r_cmd, stdout=subprocess.PIPE, encoding='utf-8', shell=True)
        fname = os.path.join(outdir, "cromwell_samples.tsv")
        with open(fname, 'w') as out_handle:
            out_handle.write(cmd.stdout)
        return fname

    d = {}
    d['compare_vcf_files.inputSamplesFile'] = _create_cromwell_samples(f1, f2, outdir)
    d['compare_vcf_files.outdir'] = final_dir + "/"
    input_file = os.path.join(outdir, 'cromwell_inputs.json')
    with open(input_file, "w") as out_handle:
        json.dump(d, out_handle)
    return input_file
