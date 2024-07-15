output "route_table_ids" {
    value = aws_route_table.rt_table.id
}

output "subnet_ids" {
    value = aws_subnet.main.id
}