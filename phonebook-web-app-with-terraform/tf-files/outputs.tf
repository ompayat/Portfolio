output "dns-name" {
  value = "http://${aws_alb.app-lb.dns_name}"
}

output "websiteurl" {
  value = "http://${aws_route53_record.phonebook.name}"
}

output "db-addr" {
  value = aws_db_instance.db-server.address
}

output "db-endpoint" {
  value = aws_db_instance.db-server.endpoint
}