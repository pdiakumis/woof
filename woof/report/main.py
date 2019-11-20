import os
import sys
import subprocess
import click
from click import echo, style
from woof import utils

report_opts = {
    "types": [
        "compare"
    ]
}

@click.command()
@click.option("-t", "--type", type=click.Choice(report_opts["types"]), help="Type of report (def: compare)", default="compare")
@click.option("-w", "--woof-final", "woof_final", type=click.Path(exists=True), help="Path to woof/final directory")
@click.option("--r1", "--run1-name", "run1_name", help="Run1 name (def: run1)", default="run1")
@click.option("--r2", "--run2-name", "run2_name", help="Run2 name (def: run2)", default="run2")
@click.option("-o", "--output", help="Output HTML file name")
def report(type, output, woof_final, run1_name, run2_name):
    echo(click.style(f"[{utils.timestamp()}] woof-report start", fg="yellow"))
    echo(style(f"report type is {type}", fg="green"))

    if not output:
        output = f"woof_{type}"
    output = os.path.join(os.getcwd(), output)
    woof_final = utils.adjust_path(woof_final)

    if type == "compare":
        if not woof_final:
            utils.critical(f"ERROR: you need to point to 'woof/final' using the '--woof-final` option.")

        render_rmd = (
            f"Rscript --vanilla -e "
            f"\""
            f"library(rmarkdown); "
            f"rmd <- system.file('rmd', 'woof_compare.Rmd', package='woofr'); "
            f"rmarkdown::render(input = rmd, output_file = '{output}', "
            f"params = list("
            f" woof_final = '{woof_final}', "
            f" run1_nm = '{run1_name}', "
            f" run2_nm = '{run2_name}' "
            f"))"
            f"\""
        )

        # print(render_rmd)
        subprocess.run(render_rmd, stdout=subprocess.PIPE, encoding="utf-8", shell=True)

    echo(click.style(f"[{utils.timestamp()}] woof-report end", fg="yellow"))
