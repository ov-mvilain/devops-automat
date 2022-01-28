# cloud-setup README

This terraform workspace sets up the basic networking and launches two instances for access and control
of all automation.

It should be run first before running any of the other workspaces.  It requires a public and private key pair
named `devops_rsa` and `devops_rsa.pub` to exist in this directory.  The automation will fail if these files are not present. This key pair is added to AWS as **devops_key**.

## Requirements


## Procedure