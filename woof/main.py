import os
from os.path import isfile, join, dirname, abspath
import sys
import subprocess
import click
from click import echo

from woof import _version as version
from woof import dog

@click.command()
@click.version_option(version.__version__)
@click.argument('main_command')

def main(main_command):
    """woof main runner script"""
    echo("Hello World!")
    echo(dog.dog)
    echo(main_command)
    echo(main_command)

