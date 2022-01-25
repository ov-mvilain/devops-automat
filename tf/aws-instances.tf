// aws-devops-instances-centos.tf -- define the devops aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE (in aws-keys.tf)
//================================================== NETWORK+SUBNETS+ACLs (aws-vpc.tf)
//================================================== SECURITY GROUPS (in aws-vpc-sg.tf)
//================================================== INSTANCES
# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
## ./aws-list-gold-ami.py -t aws-list-gold-template.j2 > aws-vars.tf
# to generate vars below

# os tag determines what part of the ansible inventory the instance gets sorted into

# AWS uses hostnames in the form ip-xxx-xxx-xxx-xxx.REGION.compute.internal
# with cloud-init setup to disallow setting the hostname
# https://forums.aws.amazon.com/thread.jspa?threadID=165077
# https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/

module "devops_bastion" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = "bastion"  # defined in aws-vars.tf
  ami                    = var.aws_am2_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain      # defined in aws-vars.tf

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.devops_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.devops_sg.id ]
  subnet_id              = aws_subnet.devops_subnet_pub.id
  tags = {
    Terraform   = "true"
    Environment = "bastion"
    os          = "am2"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

    amazon-linux-extras install -y epel ansible=2.8 python3.8
    yum-config-manager --enable epel
    yum update -y
    yum install -y git zsh
    pip3 install aws-mfa
  EOF
}

module "devops_automat" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = "automat"  # defined in aws-vars.tf
  ami                    = var.aws_am2_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain      # defined in aws-vars.tf

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.devops_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.devops_sg.id ]
  subnet_id              = aws_subnet.devops_subnet_priv.id
  tags = {
    Terraform   = "true"
    Environment = "automat"
    os          = "am2"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

    amazon-linux-extras install -y epel ansible=2.8 python3.8
    yum-config-manager --enable epel
    yum update -y
    yum install -y git zsh
    pip3 install aws-mfa
  EOF
}
