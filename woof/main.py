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
from .report import main as report


@click.group(context_settings=dict(help_option_names=['-h', '--help']))
@click.version_option(version.__version__)
def cli():
    """Bioinformatic Workflows"""


cli.add_command(compare.compare)
cli.add_command(dog.woof)
cli.add_command(report.report)
cli.add_command(validate.validate)

