import os
import sys
import subprocess
import click
from click import echo, style
from woof import utils
from woof.cromwell import run

@click.command()
@click.option("-n", "--name", "name", metavar="<name>", help="Name to use for specific run")
@click.option("-t", "--tsv-input", "tsv_input", help="TSV file with basename | s3_path | filetype")
def validate(dirpath):
    """Validate NGS data.

    """

    echo(style("In validate.main", fg='yellow'))
    echo(click.style(f"[{utils.timestamp()}] woof-validate start", fg='yellow'))

    echo(f'<dirpath> is {dirpath}')
    work_dir, final_dir = utils.setup_woof_dirs(outdir)


    echo(style(f"[{utils.timestamp()}] woof-validate end", fg='yellow'))

