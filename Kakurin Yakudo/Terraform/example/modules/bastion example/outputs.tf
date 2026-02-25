output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "bastion_ssh_port" {
  value = var.ssh_port
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "bastion_iam_role" {
  value = aws_iam_role.bastion_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.bastion_profile.name
}

output "security_group_id" {
  value = aws_security_group.bastion_sg.id
}