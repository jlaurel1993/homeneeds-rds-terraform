output "rds_endpoint" {
  description = "Connect here from clients"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}

output "rds_db_name" {
  value = aws_db_instance.mysql.db_name
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
