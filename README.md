# devops-automat -- install and configure OneValley DevOps automation

This project uses Vagrant to create an AWS Linux 2 VirtualBox,
locally installs tools required to develop, build, and configure 
cloud infrastructure and install these tools on a cloud instance 
(aka "automat") which will used in production.

see https://gsvlabs.atlassian.net/wiki/spaces/ENG/pages/edit-v2/1880227841
for detailed instructions.

## Requirements

This project requires

- a MacOS laptop capable of running MacOS 10.15 or later
- AWS access keys with sufficient privileges to deploy OpenValley infrastructure

## Procedure

On a new MacOS laptop (10.15 or later), setup github access by installing keys in the .ssh directory.

- brew package manager
- AWS cli
- terraform
- ansible
- virtualbox?
- an AWS account with sufficient privilges to
- create and manage EC2 instances
- create and manage RDS databases
- create and manage VPC networks, subnets, and routes
- run automation on AWS
- (aws mfa tool)[https://github.com/broamski/aws-mfa]

From the laptop, use the aws-mfa tool to temporarily grant API access to AWS. You can test this by typing
`aws s3 ls` and the OneValley S3 buckets will be listed.

The current version of this project will spin up:

- 1 VPC with two subnets, one publically accessible and one that's private
- 2 instances with the same key `devops-rsa`:
  1. bastion in the public subnet
  2. automat in the private subnet

To log into the bastion, use the AWS consol to get the bastion and automat instance IP addresses.
Or use the following aws cli query:
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
--query 'Reservations[*].Instances[*].[Tags[?Key==`Name`]|[0].Value,PrivateIpAddress, PublicIpAddress]' \
--output text
```
The private IP address is in the 2nd column and the public IP is in the third.

Use the following commands on the terminal to login into the bastion from a Mac laptop:
```bash
ssh-add -K devops-rsa
ssh -A ec2-user@<BASTION-IP>
```

Once you're logged into the bastion, use the following command to login to the automat instance:
```bash
ssh -K ec2-user@<AUTOMAT-IP>
```


https://acloud.guru/forums/aws-certified-developer-associate/discussion/-KWA3sjYYQuoKyORLMnr/ec2-instance-in-private-vpc-subnet-throwing-yum-error
