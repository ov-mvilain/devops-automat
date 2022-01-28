# cloud-setup README

This terraform workspace assumes the basic networking (vpc, 2 subnets, nat, routes, security groups, 2 instances) have already been created.  Run the terraform scripts in the `cloud-setup` directory befor running these scripts.


## Requirements


## Procedure


## NOTES

https://medium.com/@vankhoa011/how-i-use-terraform-to-restore-the-latest-snapshot-from-productions-db-to-staging-s-db-aws-rds-6ad4f6620df2

https://discuss.hashicorp.com/t/rds-restored-from-snapshot-is-destroyed-on-next-terraform-apply/3693/4
```
resource "aws_db_instance" "mydb" {
  ....
  snapshot_identifier         = "${var.db_snapshot_identifier}"
  lifecycle {
    ignore_changes = ["snapshot_identifier"]
  }
}
```

https://stackoverflow.com/questions/51486890/creating-rds-instances-from-snapshot-using-terraform/51487115
```
# Get latest snapshot from production DB
data "aws_db_snapshot" "db_snapshot" {
    most_recent = true
    db_instance_identifier = "${var.db_instance_to_clone}"
}

#Create RDS instance from snapshot
resource "aws_db_instance" "primary" {
    identifier = "${var.app_name}-primary"
    snapshot_identifier = "${data.aws_db_snapshot.db_snapshot.id}"
    instance_class = "${var.instance_class}"
    vpc_security_group_ids = ["${var.security_group_id}"]
    skip_final_snapshot = true
    final_snapshot_identifier = "snapshot"
    parameter_group_name = "${var.parameter_group_name}"
    publicly_accessible = true
    timeouts {
      create = "2h"
    }
}
```

[module to consider later](https://github.com/traveloka/terraform-aws-rds-postgres)