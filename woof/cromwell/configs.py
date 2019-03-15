
OPTIONS = { "final_workflow_outputs_dir" : "",
            "default_runtime_attributes": {}
            }

CROMWELL_CONFIG = """
include required(classpath("application"))

system {
  workflow-restart = true
}
call-caching {
  enabled = true
}
load-control {
  # Avoid watching memory, since the load-controller stops jobs on local runs
  memory-threshold-in-mb = 1
}

%(database)s

%(engine)s

backend {
  providers {
    Local {
      config {
        %(joblimit)s
        runtime-attributes = \"\"\"
        Int? cpu
        Int? memory_mb
        %(docker_attrs)s
        \"\"\"
        %(submit_docker)s
        %(filesystem)s
      }
    }
%(hpc)s
%(cloud)s
  }
}
"""

DATABASE_CONFIG = """
database {
  profile = "slick.jdbc.HsqldbProfile$"
  db {
    driver = "org.hsqldb.jdbcDriver"
    url = "jdbc:hsqldb:file:%(dir_name)s/persist/metadata;shutdown=false;hsqldb.tx=mvcc"
    connectionTimeout = 200000
  }
}
"""


HPC_CONFIGS = {
"slurm": """
    SLURM {
      actor-factory = "cromwell.backend.impl.sfs.config.ConfigBackendLifecycleActorFactory"
      config {
        %(joblimit)s
        runtime-attributes = \"\"\"
        Int cpu = 1
        Int memory_mb = 2048
        String queue = "%(queue)s"
        String timelimit = "%(timelimit)s"
        String account = "%(account)s"
        %(docker_attrs)s
        \"\"\"
        submit = \"\"\"
            sbatch -J ${job_name} -D ${cwd} -o ${out} -e ${err} -t ${timelimit} -p ${queue} \
            ${"--cpus-per-task=" + cpu} --mem=${memory_mb} ${account} \
            --wrap "/usr/bin/env bash ${script}"
        \"\"\"
        kill = "scancel ${job_id}"
        check-alive = "squeue -j ${job_id}"
        job-id-regex = "Submitted batch job (\\\\d+).*"
        %(filesystem)s
      }
    }
""",
"pbspro": """
    PBSPRO {
      actor-factory = "cromwell.backend.impl.sfs.config.ConfigBackendLifecycleActorFactory"
      config {
        %(joblimit)s
        runtime-attributes = \"\"\"
        Int cpu = 1
        Int memory_mb = 2048
        String queue = "%(queue)s"
        String account = "%(account)s"
        String walltime = "%(walltime)s"
        %(docker_attrs)s
        \"\"\"
        submit = \"\"\"
        qsub -V -l wd -N ${job_name} -o ${out} -e ${err} -q ${queue} -l walltime=${walltime} \
        %(cpu_and_mem)s \
        -- /usr/bin/env bash ${script}
        \"\"\"
        kill = "qdel ${job_id}"
        check-alive = "qstat -j ${job_id}"
        job-id-regex = "(\\\\d+).*"
        %(filesystem)s
      }
    }

""",
}

CLOUD_CONFIGS = {
"AWSBATCH": """
    AWSBATCH {
          actor-factory = "cromwell.backend.impl.aws.AwsBatchBackendLifecycleActorFactory"
          config {
            root = "%(cloud_root)s/cromwell-execution"
            auth = "default"

            numSubmitAttempts = 3
            numCreateDefinitionAttempts = 3

            default-runtime-attributes {
              queueArn: "%(cloud_project)s"
            }
            filesystems {
              s3 {
                auth = "default"
              }
            }
          }
        }
""",
"FOO": """
    FOO {}
"""
}

AUTH_CONFIG_AWS = """
aws {
  application-name = "cromwell"
  auths = [{
      name = "default"
      scheme = "default"
  }]
  region = "%s"
}
"""

FILESYSTEM_CONFIG = {
  "http": """
        http { }
  """,
  "http_container": """
        http { }
  """,
  "local": """
        local {
          localization: ["soft-link"]
          caching {
            duplication-strategy: ["soft-link"]
            hashing-strategy: "path"
          }
        }
""",
  "local_container": """
        local {
          localization: ["hard-link", "copy"]
          caching {
            duplication-strategy: ["hard-link", "copy"]
            hashing-strategy: "file"
          }
        }
"""
}

