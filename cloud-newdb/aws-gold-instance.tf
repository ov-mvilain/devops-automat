// aws-devops-instances-centos.tf -- define the devops aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE (in aws-keys.tf)
//================================================== NETWORK+SUBNETS+ACLs (aws-vpc.tf)
//================================================== SECURITY GROUPS (in aws-vpc-sg.tf)
//================================================== INSTANCE AUTOMAT
# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
## ./aws-list-gold-ami.py -t aws-list-gold-template.j2 > aws-vars.tf
# to generate vars below

# os tag determines what part of the ansible inventory the instance gets sorted into

# AWS uses hostnames in the form ip-xxx-xxx-xxx-xxx.REGION.compute.internal
# with cloud-init setup to disallow setting the hostname
# https://forums.aws.amazon.com/thread.jspa?threadID=165077
# https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/

## gold instance and security groups
module "devops_app" {
  source                      = "./terraform-modules/terraform-aws-ec2-instance"

  name                        = "gold-conflence"  # defined in aws-vars.tf
  ami                         = var.aws_am2_ami   # defined in aws-vars.tf
  # domain                      = var.aws_domain      # defined in aws-vars.tf

  instance_type               = "t2.micro" #"m5a.large"
  instance_count              = 1
  key_name                    = var.aws_key_pair
  monitoring                  = true
  vpc_security_group_ids      = [ data.aws_security_group.devops_automat_sg.id ]
  subnet_id                   = data.aws_subnet.devops_subnet1_priv.id
  associate_public_ip_address = false
  source_dest_check           = false
  tags = {
    Terraform   = "true"
    Environment = "gold-conflence"
    os          = "am2"
  }
  user_data = <<-EOF
#!/bin/bash
echo "================================================== $(date) installing epel ansible python 3.8"
amazon-linux-extras install -y epel ansible2=2.8 python3.8
yum-config-manager --enable epel
echo "================================================== $(date) installing git zsh"
yum install -y git zsh

echo "================================================== $(date) installing ohmyzsh and configuring"
curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
sed -i.bak -e "s@$HOME/root@$HOME@" /root/.zshrc
cp automat/robbyrussell.zsh-theme /root/.oh-my-zsh/themes/
rsync -a --chown ec2-user /root/.oh-my-zsh /home/ec2-user
rsync -av --chown ec2-user /root/.zshrc /home/ec2-user
echo "================================================== $(date) setting shell to /bin/zsh"
sed -i.bak -e "s@ec2-user:/bin/bash@ec2-user:/bin/zsh@" /etc/passwd


echo "================================================== $(date) yum update"
yum update -y
  EOF
}

// following security groups exist...this will file if they don't
// devops_automat_sg
data "aws_security_group" "devops_automat_sg" {
  filter {
    name   = "tag:Name"
    values = ["devops_automat_sg"]
  }
}

