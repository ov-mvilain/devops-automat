// aws-vpc.tf -- define the devops aws vpc
// ================================================= NETWORK+SUBNETS+ACLs
data "aws_vpc" "default" {
  default    = true
}

#data "aws_subnet_ids" "default" {
#vpc_id    = data.aws_vpc.default.id
#}
# data.aws_subnet_ids.default.ids lists region's default subnet ids

## data "aws_availability_zones" "available" {
##   state    = "available"
## }
### data.aws_availability_zones.available.names is list region's availability zones
### data.aws_availability_zones.available.zone_ids is list region's availability zone ids

resource "aws_vpc" "devops_vpc1" {
  cidr_block           = var.aws_devops_vpc1_cidr
  enable_dns_hostnames = true

  tags = {
    Name      = "devops-vpc",
    Terraform = "True"
  }
}

//--------- PUBLIC SUBNET with 1 availability zone
resource "aws_subnet" "devops_subnet1_pub" {
  vpc_id                  = aws_vpc.devops_vpc1.id
  cidr_block              = var.aws_devops_subpub1_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.aws_avz[0]

  tags = {
    Name      = "devops_subnet1_pub",
    Terraform = "True"
  }
  depends_on = [aws_internet_gateway.devops_gw]
}
//--------- route traffic for public subnet
resource "aws_route_table" "devops_rt_pub" {
  vpc_id = aws_vpc.devops_vpc1.id
  route {
    cidr_block             = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.devops_gw.id
  }

  tags = {
    Name      = "devops_rt_pub",
    Terraform = "True"
  }
}
resource "aws_internet_gateway" "devops_gw" {
  vpc_id      = aws_vpc.devops_vpc1.id

  tags = {
    Name = "devops-gw",
    Terraform = "True"
  }
}
resource "aws_route_table_association" "devops_subnet1_rta_pub" {
  subnet_id      = aws_subnet.devops_subnet1_pub.id
  route_table_id = aws_route_table.devops_rt_pub.id
}

//--------- PRIVATE SUBNET with 1 availability zone
resource "aws_subnet" "devops_subnet1_priv" {
  vpc_id                  = aws_vpc.devops_vpc1.id
  cidr_block              = var.aws_devops_subpriv1_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.aws_avz[0]

  tags = {
    Name      = "devops_subnet1_priv",
    Terraform = "True"
  }
}
//--------- route traffic for private subnet
resource "aws_route_table" "devops_rtb_priv" {
  vpc_id = aws_vpc.devops_vpc1.id
  route {
    cidr_block             = "0.0.0.0/0"
    gateway_id             = aws_nat_gateway.devops_nat.id
  }

  tags = {
    Name      = "devops_rtb_priv",
    Terraform = "True"
  }
}
resource "aws_eip" "devops_nat_eip_ip" {
  vpc            = true
}

# be sure to DISABLE "source destination check" so private traffic isn't checked
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#EIP_Disable_SrcDestCheck
# https://bobcares.com/blog/update-yum-without-internet-access-on-ec2/
# https://acloud.guru/forums/aws-certified-developer-associate/discussion/-KWA3sjYYQuoKyORLMnr/ec2-instance-in-private-vpc-subnet-throwing-yum-error
resource "aws_nat_gateway" "devops_nat" {
  allocation_id     = aws_eip.devops_nat_eip_ip.id
  subnet_id         = aws_subnet.devops_subnet1_priv.id
  connectivity_type = "public"

  tags = {
    Name = "devops_nat",
    Terraform = "True"
  }
  depends_on     = [ aws_eip.devops_nat_eip_ip ]
}

resource "aws_route_table_association" "devops_subnet1_rtb" {
  subnet_id      = aws_subnet.devops_subnet1_priv.id
  route_table_id = aws_route_table.devops_rtb_priv.id
}

//--------- NETWORK ACLs
## apply network ACLs to VPC to restrict access to entire VPC
## rather Security Groups which are per instance
## sadly network_acl_rules don't take descriptions
##
resource "aws_network_acl" "devops_acl" {
  vpc_id      = aws_vpc.devops_vpc1.id
  subnet_ids  = [ aws_subnet.devops_subnet1_pub.id, aws_subnet.devops_subnet1_priv.id ]
  tags = {
    Name      = "devops-acl",
    Terraform = "True"
  }
}

## default network_acl settings
##
resource "aws_network_acl_rule" "devops_acl_egress" {
  network_acl_id = aws_network_acl.devops_acl.id
  rule_number    = 200
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
resource "aws_network_acl_rule" "devops_acl_http" {
  network_acl_id = aws_network_acl.devops_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
