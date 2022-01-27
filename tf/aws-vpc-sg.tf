// aws-vpc-sg.tf -- define global aws vpc's security groups & network ACLs
// for instance-specific secrurity groups see aws-instance-*.tf
// ================================================= SECURITY GROUPS
# apply network ACLs to VPC to restrict access to entire VPC
# rather Security Groups which are per instance
# sadly network_acl_rules don't take descriptions
# resource "aws_network_acl" "devops_acl" {

# resource "aws_network_acl_rule" "devops_acl_egress" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 200
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }
# resource "aws_network_acl_rule" "devops_acl_http" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 100
#   egress         = false
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }

# resource "aws_network_acl_rule" "devops_acl_http" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 100
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 80
#   to_port        = 80
# }
# resource "aws_network_acl_rule" "devops_acl_https" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 110
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 443
#   to_port        = 443
# }
# resource "aws_network_acl_rule" "devops_acl_ssh_home" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 120
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "75.25.136.0/24"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "devops_acl_ssh_nord8524" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 130
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "192.145.118.0/24"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "devops_acl_ssh_leaseweb80" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 180
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "23.80.0.0/15"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "devops_acl_ssh_leaseweb82" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 182
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "23.82.0.0/16"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "devops_acl_ssh_leaseweb83" {
#   network_acl_id = aws_network_acl.devops_acl.id
#   rule_number    = 183
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "23.83.0.0/18"
#   from_port      = 22
#   to_port        = 22
# }
