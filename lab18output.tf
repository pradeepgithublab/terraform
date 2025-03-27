output "vpc_id" {
  value       = aws_vpc.vpc.id
}
output "igw_id" {
  value       = aws_internet_gateway.igw.id
}
output "subnet_id" {
  value       = aws_subnet.subnet.id
}
output "vpc_flow_log_id" {
  value       = aws_flow_log.my_flow_log.id
}
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.instance.id
}           
