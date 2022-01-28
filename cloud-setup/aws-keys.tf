// aws-keys.tf -- define the devops aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== PROVIDERS (in provider-credentials.tf)
data "aws_region" "current" {}
# data.aws_region.name - The name of the selected region.
# data.aws_region.endpoint - The EC2 endpoint for the selected region.
# data.aws_region.description - region's description in this format: "Location (Region name)"

//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEY AND SAVE
# resource "tls_private_key" "devops_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = "4096"
# }

# resource "local_file" "devops_pub_ssh_key" {
#   content              = tls_private_key.devops_ssh_key.public_key_openssh
#   directory_permission = "0755"
#   file_permission      = "0600"
#   filename             = "devops_rsa.pub"
# }

# resource "local_file" "devops_priv_ssh_key" {
#   content              = tls_private_key.devops_ssh_key.private_key_pem
#   filename             = "devops_rsa"
#   directory_permission = "0755"
#   file_permission      = "0600"
# }

# resource "aws_key_pair" "devops_key" {
#   key_name   = "devops_key"
#   public_key = chomp(tls_private_key.devops_ssh_key.public_key_openssh)
# }

//================================================== USE PREVIOUSLY GENERATED KEY
//================================================== will barf if key doesn't exist
data "local_file" "devops_pub_ssh_key" {
  filename   = "${var.aws_ssh_key}.pub"
}

data "aws_key_pair" "devops_key" {
  key_name   = var.aws_key_pair
  # public_key = data.local_file.devops_pub_ssh_key.content
}
#id - The key pair name.
#arn - The key pair ARN.
#key_name - The key pair name.
#key_pair_id - The key pair ID.
#fingerprint - The MD5 public key fingerprint as specified in section 4 of RFC 4716.
#tags_all
