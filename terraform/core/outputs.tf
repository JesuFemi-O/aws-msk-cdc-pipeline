output "db_password_secret" {
    value = aws_rds_cluster.my_rds_cluster.master_user_secret
}

output "db_instance_name" {
    value = aws_rds_cluster.my_rds_cluster.database_name
  
}