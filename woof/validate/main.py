import os
from os.path import isfile, join, dirname, abspath
import sys
import subprocess
import click
from click import echo

@click.command()
@click.argument("input", type=click.File(), metavar="<input>")
@click.option('--hpc', type=click.Choice(['local', 'spartan', 'raijin', 'aws']),
              required=False, help="HPC system used")
def validate(input, hpc):
    """Validate NGS data"""
    echo(click.style("In validate.main", fg='blue'))
    echo(f'input is {input}; hpc is {hpc}')

