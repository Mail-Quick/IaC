output "vpc_id" {
  value = aws_vpc.default.id
}

output "db_subnet_id1" {
  value = element(aws_subnet.private_db.*.id, 0)
}

output "db_subnet_id2" {
  value = element(aws_subnet.private_db.*.id, 1)
}

