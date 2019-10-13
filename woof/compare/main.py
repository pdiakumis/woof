import json
import os
import sys
import subprocess
import click
from click import echo, style
from woof import utils
from woof.cromwell import run

comp_opts = {
    "types": [
        "bc_dna", "um_dna",
        # "bc_rna", "um_rna",
        # "dr_dna", "dr_rna"
        ],
    "genomes": ["grch37", "hg38"],
}

@click.command()
@click.argument("r1", type=click.Path(exists=True), metavar="<run1>")
@click.argument("r2", type=click.Path(exists=True), metavar="<run2>")
@click.option("-t", "--type", default="bc_dna", type=click.Choice(comp_opts["types"]), help="[NOT USED YET] Type of comparison [def: bc_dna]")
@click.option("-s", "--sample", "sample", required=True, help="Sample/batch name")
@click.option("-o", "--outdir", help="Output directory [def: ./woof]", default="woof")
@click.option("-p", "--justprep", "justprep", is_flag=True, help="Just prepare Cromwell inputs and print the Cromwell command to STDOUT")
def compare(r1, r2, type, sample, outdir, justprep=False):
    """Compare two bcbio/umccrise/dragen WGS/WTS runs.

    DRAGEN, WTS: TODO
    """
    echo(click.style(f"[{utils.timestamp()}] woof-compare start", fg="yellow"))

    r1 = utils.adjust_path(r1)
    r2 = utils.adjust_path(r2)

    comp_type = comparison_type_check(r1, r2)
    echo(style(f"comparison type is {comp_type}", fg="green"))
    echo(style(f"sample is {sample}", fg="green"))

    work_dir, final_dir = utils.setup_woof_dirs(outdir, sample)
    input_file = create_cromwell_input(r1, r2, sample, work_dir, final_dir, comp_type)
    wdl_workflow = os.path.join(work_dir, "wdl", "compare.wdl")
    run.run_cromwell(outdir, sample, input_file, wdl_workflow, justprep)
    echo(style(f"[{utils.timestamp()}] woof-compare end", fg="yellow"))

def comparison_type_check(r1, r2):

    # TODO: Add DRAGEN option
    # TODO: Take in a TSV file with inputs and skip altogether
    comparison_type = None

    def _is_bcbio_final(d):
        return os.path.basename(d) == "final"

    def _is_umccrise_sample(d):
        return os.path.basename(os.path.dirname(d)) == "umccrised"

    if _is_bcbio_final(r1) and _is_bcbio_final(r2):
        comparison_type = "bcbio"
    elif _is_umccrise_sample(r1) and _is_umccrise_sample(r2):
        comparison_type = "umccrise"
    else:
        utils.critical(f"ERROR: you need to point to 'final' or 'umccrised/<sample>' paths.")
    return comparison_type




def create_cromwell_input(r1, r2, sample, outdir, final_dir, comp_type):

    def _create_cromwell_samples(r1, r2, sample, outdir, comp_type):
        r_cmd = None
        if comp_type == "bcbio":
            r_cmd = f"Rscript --no-environ -e \"library(woofr); woofr::merge_bcbio_outputs('{r1}', '{r2}', '{sample}')\""
        elif comp_type == "umccrise":
            r_cmd = f"Rscript --no-environ -e \"library(woofr); woofr::merge_umccrise_outputs('{r1}', '{r2}', '{sample}')\""
        cmd = subprocess.run(r_cmd, stdout=subprocess.PIPE, encoding="utf-8", shell=True)
        fname = os.path.join(outdir, "cromwell_samples.tsv")
        with open(fname, "w") as out_handle:
            out_handle.write(cmd.stdout)
        return fname

    d = {}
    d["compare_vcf_files.inputSamplesFile"] = _create_cromwell_samples(r1, r2, sample, outdir, comp_type)
    d["compare_vcf_files.outdir"] = final_dir + "/"
    input_file = os.path.join(outdir, "cromwell_inputs.json")
    with open(input_file, "w") as out_handle:
        json.dump(d, out_handle)
    return input_file

