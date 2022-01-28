// aws-keys.tf -- define the devops aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== PROVIDERS (in provider-credentials.tf)
# Configure the AWS Provider
provider "aws" {
  # alias  = "east"
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
}
