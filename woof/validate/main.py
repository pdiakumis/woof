import os
import sys
import subprocess
import click
from click import echo, style
from woof import utils
from woof.cromwell import run

@click.command()
@click.argument("dirpath", type=click.File(), metavar="<dirpath>")
def validate(dirpath):
    """Validate NGS data in <dir>"""

    echo(click.style("In validate.main", fg='blue'))

    dirpath = utils.adjust_path(dirpath)

    echo(f'<dirpath> is {dirpath}')
