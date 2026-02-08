output "nat_proxy_ip" {
  value = aws_eip.nat.public_ip
}

output "security_group_id" {
  value = aws_security_group.nat_proxy.id
}
