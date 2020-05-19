output "bastion_public_ip" {
  value = aws_instance.lw-lab-bastion.public_ip
}