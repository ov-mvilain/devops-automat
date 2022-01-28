# cloud-setup README

This terraform workspace sets up the basic networking and launches two
instances for access and control of all automation.

It should be run first before running any of the other workspaces.  It
requires a public and private key pair named `devops_rsa` and
`devops_rsa.pub` to exist in this directory.  The name is defined in
the `aws-vars.tf` file.

The automation will fail if the ssh key files are not present. The key pair 
must be added to AWS prior to running the automation.  The name is defined
in the `aws-vars.tf` file.

## Requirements

To deploy this workspace on a laptop to which creates an autmation instance
inside AWS, you need

- AWS API keys
- terraform installed on a local system


## Procedure


## NOTES

The S3 backend is untested.