// aws-rds-pg.tf -- define aws RDS database, security groups, & network ACLs
// for instance-specific secrurity groups see aws-instance-*.tf
// ================================================= SECURITY GROUPS
// this assumes the cloud-setup workspace has been executed and the
// following security groups exist...this will file if they don't
// devops_db_sg
data "aws_security_group" "devops_db_sg" {
  filter {
    name   = "tag:Name"
    values = ["devops_db_sg"]
  }
}
