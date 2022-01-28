// aws-network.tf -- define the devops aws vpc
// ================================================= NETWORK
#data "aws_subnet_ids" "default" {
#vpc_id    = data.aws_vpc.default.id
#}
# data.aws_subnet_ids.default.ids lists region's default subnet ids

## data "aws_availability_zones" "available" {
##   state    = "available"
## }
### data.aws_availability_zones.available.names is list region's availability zones
### data.aws_availability_zones.available.zone_ids is list region's availability zone ids

data "aws_vpc" "devops_vpc1" {
  filter {
    name   = "tag:Name"
    values = ["devops-vpc"]
  }
}

//--------- PUBLIC SUBNET with 1 availability zone
data "aws_subnet" "devops_subnet1_pub" {
  filter {
    name   = "tag:Name"
    values = ["devops_subnet1_pub"]
  }
}

//--------- PRIVATE SUBNET with 1 availability zone
data "aws_subnet" "devops_subnet1_priv" {
  filter {
    name   = "tag:Name"
    values = ["devops_subnet1_priv"]
  }
}
