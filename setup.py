#!/usr/bin/env python

from setuptools import setup, find_packages
import os

__version__ = "0.0.0.1"

with open("./README.md", "r") as readme:
    long_description = readme.read()

def write_version_py():
    version_py = os.path.join(os.path.dirname(__file__), 'woof', '_version.py')
    try:
        import subprocess
        p = subprocess.Popen(["git", "rev-parse", "--short", "HEAD"],
                             stdout=subprocess.PIPE)
        githash = p.stdout.read().decode('utf-8').strip()
    except:
        githash = ""
    with open(version_py, "w") as out_handle:
        out_handle.write("\n".join(['__version__ = "%s"' % __version__,
                                    '__git_revision__ = "%s"' % githash]))

write_version_py()

install_requires = ["Click",]

setup(
    name="woof",
    version=__version__,
    license="MIT",
    author="Peter Diakumis",
    author_email="peterdiakumis@gmail.com",
    description="Woofing Workflows",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/pdiakumis/woof",
    packages=find_packages(),
    install_requires=install_requires,
    include_package_data=True,
    entry_points='''
        [console_scripts]
        woof=woof.main:cli
    ''',
    )

