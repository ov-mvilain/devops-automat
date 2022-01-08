# automat -- install and configure OneValley automation

This project uses Vagrant to create an AWS Linux 2 VirtualBox,
locally installs tools required to develop, build, and configure 
cloud infrastructure and install these tools on a cloud instance 
(aka "automat") which will used in production.


## Requirements

This project requires

- a MacOS laptop capable of running 
  - Apple XCode
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

