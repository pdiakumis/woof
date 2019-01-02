from setuptools import setup, find_packages

with open("./README.md", "r") as fh:
    long_description = fh.read()

setup(
    name = "woof",
    version = "0.0.1",
    license = "MIT",
    author = "Peter Diakumis",
    author_email = "peterdiakumis@gmail.com",
    description = "Woofing Snakemake Workflows for UMCCR",
    long_description = long_description,
    long_description_content_type = "text/markdown",
    url = "https://github.com/umccr/woof",
    packages = ["woof"],
    entry_points = {
        'console_scripts': [
            'woof = woof.__main__:main'
            ]
        }
    )
