// aws-rds-pg.tf -- define aws RDS database, security groups, & network ACLs
// for instance-specific secrurity groups see aws-instance-*.tf
// ================================================= SECURITY GROUPS
resource "aws_security_group" "devops_db_sg" {
  name        = "devops_db_sg"
  description = "RDS pg traffic"
  vpc_id      = aws_vpc.devops_vpc1.id

  tags = {
    Name      = "devops_db_sg",
    Terraform = "True"
  }
}

//----------------------------------------------------------------------egress
resource "aws_security_group_rule" "devops_db_sgr_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.devops_db_sg.id
}

//----------------------------------------------------------------------ingress
resource "aws_security_group_rule" "devops_db_sgr_pg" {
  type                     = "ingress"
  description              = "pg all"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.devops_automat_sg.id
  security_group_id        = aws_security_group.devops_db_sg.id
}
resource "aws_security_group_rule" "devops_db_sgr_bastion" {
  type                     = "ingress"
  description              = "all traffic from bastion"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.devops_bastion_sg.id
  security_group_id        = aws_security_group.devops_db_sg.id
}
resource "aws_security_group_rule" "devops_db_sgr_self" {
  type              = "ingress"
  description       = "self"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.devops_db_sg.id
}