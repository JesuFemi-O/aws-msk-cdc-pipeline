############### CREATE SUBNET GROUP AND CLUSTER PARAMETER GROUP ########################

# "aws_subnet" "dataeng_cdc_poc_private_subnets"
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "msk-cdc-rds-db-subnet-group"
  description = "RDS Database Subnet Group for logical replication setup"
  
  # Select subnets 1 and 3 explicitly to select across AZs (us-east-2a & us-east-2b)
  subnet_ids = [
    aws_subnet.msk_cdc_private_subnets["private-subnet-1"].id,
    aws_subnet.msk_cdc_private_subnets["private-subnet-3"].id
  ]

  tags = {
    Name = "msk-cdc-rds-db-subnet-group"
  }
}

# RDS Cluster Parameter Group with Logical Replication Enabled
resource "aws_rds_cluster_parameter_group" "db_cluster_parameter_group" {
  name        = "msk-cdc-enabled-rds-postgres-cluster-group"
  family      = "aurora-postgresql15"
  description = "CDC-enabled Aurora PostgreSQL cluster parameter group"

  parameter {
    name  = "rds.logical_replication"
    value = "1"
    apply_method = "pending-reboot" # Required for this parameter
  }

  tags = {
    Name = "msk-cdc-enabled-rds-postgres-group"
  }
}


########################## CREATE DB CLUSTER AND CLUSTER INSTANCE ###########################

# RDS Cluster with the Parameter Group Attached
resource "aws_rds_cluster" "my_rds_cluster" {
  cluster_identifier              = "cdc-rds-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = "15.4"
  master_username                 = var.rds_master_user
  manage_master_user_password     = true
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.rds_security_group.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_cluster_parameter_group.name
  skip_final_snapshot             = true

  # Other necessary configurations for your RDS cluster
}

# Primary RDS Cluster Instance
resource "aws_rds_cluster_instance" "primary_instance" {
  identifier          = "cdc-rds-cluster-primary"
  cluster_identifier  = aws_rds_cluster.my_rds_cluster.cluster_identifier
  instance_class      = "db.t3.medium" # Adjust as needed
  engine              = "aurora-postgresql"
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  # Set as primary instance (default behavior for the first instance)
  apply_immediately = true
}