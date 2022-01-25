#am2...[done]
// generated from devops-aws-vars.j2 -- jinja2 template to provide devops aws instances
// [template for aws-list-gold-ami.py]
//================================================== VARIABLES
variable "aws_region" {
  description = "default region to setup all resources"
  type        = string
  default     = "us-east-2"
}
variable "aws_domain" {
  description = "DNS domain where aws instances are running"
  type        = string
  default     = "gsvlabs.com" #"aws-vilain.com"
}

#========================================== AVAILABILTY ZONES
variable "aws_avz" {
  description = "us-east-2-zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

#========================================== am2 2022-01-05T22:17:50.000Z
variable "aws_am2_ami" {
  description = "us-east-2--Amazon Linux 2 AMI 2.0.20211223.0 x86_64 HVM gp2"
  type        = string
  default     = "ami-066157edddaec5e49"
}
variable "aws_am2_name" {
  description = "name for am2 instance"
  type        = string
  default     = "devops-am2"
}
variable "aws_am2_tag" {
  description = "tag for am2 instance"
  type        = string
  default     = "devops-am2"
}


