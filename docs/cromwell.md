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

<!-- vim-markdown-toc -->

### S3 bucket
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/aws-genomics-s3.template.yaml)

### EC2 Launch Template
* Use cf template
  [here](https://github.com/aws-samples/aws-genomics-workflows/blob/master/src/templates/aws-genomics-launch-template.template.yaml)
* Has a LaunchTemplateID under Outputs (e.g. `lt-12345`)

### Key Pairs
* Create new EC2 Key Pair [here](https://ap-southeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-southeast-2#KeyPairs:sort=keyName)
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

* VPC ID: use something like `vpc-005b.. (vpc-bootstrap-main)`
* VPC Subnet ID: use something like `subnet-0345.. (vpc-bootstrap-main-public-2)`

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


