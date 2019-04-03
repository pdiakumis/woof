"""Run Cromwell with config, input and options"""

import os
import sys
import subprocess
import json
import pkg_resources
from woof import utils
from woof.cromwell import configs

def create_cromwell_files(outdir):
    """
    Writes following to <outdir>/work:
    1. config
    2. options
    3. all WDL files
    """

    outdir = utils.adjust_path(outdir)
    work_dir = os.path.join(outdir, "work")
    final_dir = os.path.join(outdir, "final")

    # config
    config_hocon = create_cromwell_config(work_dir)
    config_file = os.path.join(work_dir, "cromwell_config.conf")
    with open(config_file, "w") as out_handle:
        out_handle.write(config_hocon)

    # opts
    opts = configs.OPTIONS
    # maybe remove final_dir as option and work based on work_dir
    #opts["final_workflow_outputs_dir"] = final_dir
    option_file = os.path.join(work_dir, "cromwell_opts.json")
    with open(option_file, "w") as out_handle:
        json.dump(opts, out_handle)

    # pre-create log, meta
    log_file = os.path.join(work_dir, "cromwell_log.log")
    metadata_file = os.path.join(work_dir, "cromwell_meta.json")

    res = {
        "config_file": config_file,
        "option_file": option_file,
        "log_file": log_file,
        "metadata_file": metadata_file,
        }

    return res


def create_cromwell_config(outdir):
    """Create a cromwell HOCON config.
    """

    def _get_filesystem_config(file_types):
        """Retrieve filesystem configuration, including support for specified file types.
        """
        out = "     filesystems {\n"
        for file_type in sorted(list(file_types)):
            if file_type in configs.FILESYSTEM_CONFIG:
                out += configs.FILESYSTEM_CONFIG[file_type]
        out += "      }\n"
        return out

    def _get_engine_filesystem_config(file_types):
        """Retriever authorization and engine filesystem configuration.
        """
        file_types = [x for x in list(file_types)]
        out = ""
        if "s3" in file_types:
            region = "ap-southeast-2"
            out += configs.AUTH_CONFIG_AWS % region
            out += "engine {\n"
            out += "  filesystems {\n"
            out += '    s3 { auth = "default" }'
            out += "  }\n"
            out += "}\n"

        return out

    joblimit = 16 # need to play with this
    filesystem = utils.get_filesystem() # SPARTAN/RAIJIN/AWS/OTHER - dealing with single fs for now
    file_types = set(["s3" if filesystem == "AWS" else "local"])
    std_args = {"docker_attrs": "",
                "submit_docker": 'submit-docker: ""',
                "joblimit": f'concurrent-job-limit = {joblimit if joblimit > 0 else ""}',
                "filesystem": _get_filesystem_config(file_types),
                "database": configs.DATABASE_CONFIG % {"outdir": outdir}}
    conf_args = {}
    std_args["engine"] = _get_engine_filesystem_config(file_types)
    conf_args.update(std_args)
    scheduler = None
    cloud_type = None
    main_config = {"hpc": (configs.HPC_CONFIGS[scheduler] % conf_args) if scheduler else "",
                   "cloud": (configs.CLOUD_CONFIGS[cloud_type] % conf_args) if cloud_type else "",
                   "work_dir": outdir}
    main_config.update(std_args)

    return configs.CROMWELL_CONFIG % main_config

def copy_wdl_files(outdir):
    """Copy recursively WDL files (workflows + tasks) from 'woof/woof/wdl' to 'outdir/wdl'
    """
    outdir = utils.adjust_path(outdir)
    if not pkg_resources.resource_exists('woof', 'wdl'):
        utils.critical("Error: 'woof/wdl' directory does not exist!")
    d = pkg_resources.resource_filename('woof', 'wdl')
    utils.copy_recursive(d, os.path.join(outdir, 'wdl'))


def run_cromwell(outdir, inputs, workflow):
    """Run Cromwell

    cromwell run \
            --inputs <input.json> \
            --Dconfig=<config.conf> \
            --DLOG_LEVEL=<ERROR|WARN|INFO> \
            --options <options.json> \
            --metadata-output <meta.json> \
            workflow.wdl
    """

    # The only things that change depending on project_name are inputs and workflow.

    copy_wdl_files(os.path.join(outdir, "work"))
    cf = create_cromwell_files(outdir)

    cc = f"cromwell -Xms1g -Xmx3g run " \
         f"-Dconfig.file={cf['config_file']} " \
         f"-DLOG_LEVEL=ERROR -DLOG_LEVEL=WARN " \
         f"--metadata-output {cf['metadata_file']} " \
         f"--options {cf['option_file']} " \
         f"--inputs {inputs} " \
         f"{workflow} " \
         f"2>&1 | tee -a {cf['log_file']} "

    #with utils.chdir(os.path.join(outdir, "work")):
    #    subprocess.run(cc, stdout=subprocess.PIPE, encoding='utf-8', shell=True)
    print(cc)

