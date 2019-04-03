import os
import sys
import subprocess
import click
from click import echo, style
from woof import utils
from woof.cromwell import run

@click.command()
@click.argument("dirpath", type=click.File(), metavar="<dirpath>")
@click.option("-o", "--outdir", help="Output directory [def: ./woof].", default="woof")
def validate(dirpath):
    """Validate NGS data in <dirpath>"""

    echo(style("In validate.main", fg='yellow'))

    dirpath = utils.adjust_path(dirpath)
    echo(f'<dirpath> is {dirpath}')
    work_dir, final_dir = utils.setup_woof_dirs(outdir)

