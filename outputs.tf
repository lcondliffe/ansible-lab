output "bastion_public_ip" {
  value = aws_instance.ansib-lab-bastion.public_ip
}