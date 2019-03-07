import os
from os.path import isfile, join, dirname, abspath
import sys
import subprocess
import click
from click import echo


@click.command()
@click.argument("f1", type=click.Path(exists=True), metavar="<final1>")
@click.argument("f2", type=click.Path(exists=True), metavar="<final2>")
def compare(f1, f2):
    """Compare two bcbio runs <final1> and <final2>"""
    echo(click.style("In compare.main", fg='green'))
    echo(f'f1 is {f1}; f2 is {f2}')

