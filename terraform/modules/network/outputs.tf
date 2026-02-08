output "vpc_id" {
  description = "作成されたVPCのID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  value       = aws_vpc.main.cidr_block
}

output "public_subnets" {
  description = "パブリックサブネットのIDリスト"
  value       = aws_subnet.public[*].id
}

output "private_app_subnets" {
  description = "アプリ用プライベートサブネットのIDリスト"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnets" {
  description = "データ用プライベートサブネットのIDリスト"
  value       = aws_subnet.private_data[*].id
}

output "private_app_route_table_id" {
  description = "アプリ用サブネットのルートテーブルID (検証環境のEC2 NAT紐付け用)"
  value       = aws_route_table.private_app.id
}
