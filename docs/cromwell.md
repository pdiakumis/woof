Cromwell
--------

## Cromwell on AWS Batch

<!-- vim-markdown-toc GFM -->

* [S3 bucket](#s3-bucket)
* [EC2 Launch Template](#ec2-launch-template)
* [Key Pairs](#key-pairs)
* [IAM Roles](#iam-roles)
* [VPC Stuff](#vpc-stuff)
* [AWS Batch](#aws-batch)
* [Cromwell EC2 Instance](#cromwell-ec2-instance)

<!-- vim-markdown-toc -->

### S3 bucket
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/aws-genomics-s3.template.yaml)

### EC2 Launch Template
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/aws-genomics-launch-template.template.yaml)
* Has a LaunchTemplateID under Outputs (e.g. `lt-12345`)

### Key Pairs
* Create new EC2 Key Pair under Services `->` EC2 `->` Network & Security `->` Key Pairs
* Give it a name
* The private key is downloaded automatically - save in `~/.ssh/` directory
* Then do `chmod 600 key.pem && ssh-add key.pem` (`ssh-add` saves you from needing to do `ssh -i key.pem blah@blah.com`)
* You should then be able to do `ssh ec2-user@ec2-foo` to connect to the instance

### IAM Roles
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/aws-genomics-iam.template.yaml)
* Contains `BatchServiceRoleArn`, `BatchInstanceProfileArn`,
  `BatchSpotFleetRoleArn` and `BatchJobRoleArn` under Outputs

### VPC Stuff
You can see the mappings between VPCs and their subnets under Services `->` VPC `->` Your VPCs / Subnets

* VPC ID: use something like `vpc-0e47286.. (umccrise-vpc-dev)`
* VPC Subnet ID: use something like `subnet-0fb22c..`

### AWS Batch
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/aws-genomics-batch.template.yaml)
* LaunchTemplateID (from above)
* EC2 Key Pair name (from above)
* VPC ID (from above)
* VPC Subnet ID (from above)
* AWS Batch service role ARN (from above)
* EC2 Instance Profile ARN (from above)
* Spot Fleet Role ARN (from above)

### Cromwell EC2 Instance
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/cromwell/cromwell-server.template.yaml)
* VPC ID (from above)
* VPC Subnet ID (from above)
* Instance Type: `t2.micro`
* EC2 Key Pair name (from above)
* Cromwell Version: 36.1
* S3 Bucket name (from above)
* Default Batch Queue: see the Outputs from the AWS Batch stack

In the Outputs you'll see the Hostname (`ec2-foo`). You can connect to that with `ssh ec2-user@ec2-foo`. Then you'll see something like:

```
[ec2-user@ip-10-2-5-43 ~]$ ll
total 177292
-rw-r--r-- 1 ec2-user ec2-user 181525783 Apr 11 11:07 cromwell-36.1.jar
-rw-r--r-- 1 ec2-user ec2-user       893 Apr 11 11:07 cromwell.conf
lrwxrwxrwx 1 root     root            19 Apr 11 11:07 cromwell.jar -> ./cromwell-36.1.jar
-rwxr-xr-x 1 ec2-user ec2-user       215 Apr 11 11:07 get_cromwell.sh
-rwxr-xr-x 1 ec2-user ec2-user        70 Apr 11 11:07 run_cromwell_server.sh
-rw-r--r-- 1 ec2-user ec2-user      1422 Apr 11 11:07 supervisord.conf

[ec2-user@ip-10-2-5-43 ~]$ head cromwell.conf
include required(classpath("application"))

webservice {
  interface = localhost
  port = 8000
}

system {
  job-rate-control {
    jobs = 1

[ec2-user@ip-10-2-5-43 ~]$ cat run_cromwell_server.sh
#!/bin/bash
java -Dconfig.file=cromwell.conf -jar cromwell.jar server
```

The thing with the cf template above is that __it starts the Cromwell server automatically on launch__.
This means that once the stack has been created and launched successfully, you can simply do a
`ssh -L localhost:8000:localhost:8000 ec2-user@ec2-foo.ap-southeast-2.compute.amazonaws.com`
and that will open up a port between the EC2 instance running Cromwell and your local laptop.
You can then go to <http://localhost:8000/> and you'll hopefully see the Swagger UI. This means
you can now submit jobs to Cromwell using that interface, curl, or something like Postman. Awesomeness!!!

