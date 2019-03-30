import os
from os.path import isfile, join, dirname, abspath
import sys
import subprocess
import click
from click import echo

from woof import _version as version
from woof import dog, utils
from .compare import main as compare
from .validate import main as validate


@click.group(context_settings=dict(help_option_names=['-h', '--help']))
@click.version_option(version.__version__)
def cli():
    """Bioinformatic Workflows"""
    echo(click.style(f"[{utils.timestamp()}] woof start", fg='yellow'))


cli.add_command(compare.compare)
cli.add_command(validate.validate)
cli.add_command(dog.woof)
