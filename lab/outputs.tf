output "nodes_public_ips" {
  description = "Public IPs assigned to the EC2 nodes"
  value       = module.nodes.*.public_ip
}
output "controllers_public_ips" {
  description = "Public IPs assigned to the EC2 controllers"
  value       = module.controllers.*.public_ip
}
output "controller_ebs_volume_attachment_id" {
  description = "The volume ID"
  value       = aws_volume_attachment.controller_this.*.volume_id
}

output "controller_ebs_volume_attachment_instance_id" {
  description = "The instance ID"
  value       = aws_volume_attachment.controller_this.*.instance_id
}

output "nodes_ebs_volume_attachment_id" {
  description = "The volume ID"
  value       = aws_volume_attachment.node_this.*.volume_id
}

output "nodes_ebs_volume_attachment_instance_id" {
  description = "The instance ID"
  value       = aws_volume_attachment.node_this.*.instance_id
}
