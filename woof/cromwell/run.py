"""Run Cromwell with config, input and options"""

import os
import sys
from woof import utils
from woof.cromwell import configs

"""
Step 1: Create woof/work and woof/final directories 
Step 2: Generate WDL scripts, <input.json>, <config.conf>, <options.json>
"""

def create_cromwell_dirs(dname = os.getcwd()):
    """
    Create (and return) work, final directories for Cromwell
    """
    work_dir = utils.safe_mkdir(os.path.join(dname, "woof", "work"))
    final_dir = utils.safe_mkdir(os.path.join(dname, "woof", "final"))

    return {"final_dir": final_dir, "work_dir": work_dir}

def create_cromwell_files(dname):
    """
    Writes following to given dname:
    1. config
    2. options
    3. inputs.json
    4. WDL files
    """

def create_cromwell_config(dname):
    """Prepare a cromwell configuration within the specified directory.
    """
    out_file = os.path.join(dname, "woof-cromwell.conf")
    joblimit = 1
    hostname = utils.get_hostname()
    std_args = {"docker_attrs": "" if args.no_container else "\n        ".join(docker_attrs),
                "submit_docker": 'submit-docker: ""' if args.no_container else "",
                "joblimit": "concurrent-job-limit = %s" % (joblimit) if joblimit > 0 else "",
                "filesystem": _get_filesystem_config(file_types),
                "database": DATABASE_CONFIG % {"dname": dname})}
    cl_args, conf_args, scheduler, cloud_type = _args_to_cromwell(args)
    std_args["engine"] = _get_engine_filesystem_config(file_types, args, conf_args)
    conf_args.update(std_args)
    main_config = {"hpc": (HPC_CONFIGS[scheduler] % conf_args) if scheduler else "",
                   "cloud": (CLOUD_CONFIGS[cloud_type] % conf_args) if cloud_type else "",
                   "work_dir": work_dir}
    main_config.update(std_args)
    # Local run always seems to need docker set because of submit-docker in default configuration
    # Can we unset submit-docker based on configuration so it doesn't inherit?
    # main_config["docker_attrs"] = "\n        ".join(docker_attrs)
    with open(out_file, "w") as out_handle:
        out_handle.write(CROMWELL_CONFIG % main_config)
    return out_file



def run_cromwell(args):
    """Run Cromwell

    cromwell run \
            --inputs <input.json> \
            --Dconfig=<config.conf> \
            --DLOG_LEVEL=<ERROR|WARN|INFO> \
            --options <options.json> \
            --metadata-output <meta.json> \
            workflow.wdl
    """

    # The only things that change depending on project are inputs and workflow.
    # So the command should take those two as args.
    wdl_workflow, input_json, project_name = _get_main_and_json(args.directory)
    #main_file, json_file, project_name = _get_main_and_json(args.directory)
    #work_dir = utils.safe_makedir(os.path.join(os.getcwd(), "work"))
    #final_dir = utils.safe_makedir(os.path.join(work_dir, "final"))
    log_file = os.path.join(work_dir, "%s-cromwell.log" % project_name)
    metadata_file = os.path.join(work_dir, "%s-metadata.json" % project_name)
    option_file = os.path.join(work_dir, "%s-options.json" % project_name)
    cromwell_opts = {"final_workflow_outputs_dir": final_dir,
                     "default_runtime_attributes": {"bootDiskSizeGb": 20}}
    with open(option_file, "w") as out_handle:
        json.dump(cromwell_opts, out_handle)

    cmd = ["cromwell", "-Xms1g", "-Xmx3g", "run", "--type", "CWL",
           "-Dconfig.file=%s" % hpc.create_cromwell_config(args, work_dir, json_file)]
    cmd += hpc.args_to_cromwell_cl(args)
    cmd += ["--metadata-output", metadata_file, "--options", option_file,
            "--inputs", json_file, main_file]
    with utils.chdir(work_dir):
        _run_tool(cmd, not args.no_container, work_dir, log_file)
        if metadata_file and utils.file_exists(metadata_file):
            with open(metadata_file) as in_handle:
                metadata = json.load(in_handle)
            if metadata["status"] == "Failed":
                _cromwell_debug(metadata)
                sys.exit(1)
            else:
                _cromwell_move_outputs(metadata, final_dir)

