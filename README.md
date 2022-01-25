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
- access to the GSVlabs github repository
- AWS access keys with sufficient privileges to deploy OpenValley infrastructure
- 

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

