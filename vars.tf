variable "ssh_key" {
  description = "The .pem key downloaded from AWS, to be used for SSH access to lab nodes."
}
variable "ssh_key_name" {
  description = "The AWS key name defined in AWS."
}

variable "aws_region" {
  description = "The AWS region to create the lab in."
}
variable "bastion_instance_size" {
  description = "EC2 sizing of the bastion host"
  default = "t3.micro"
}
variable "node_instance_size" {
  description = "EC2 sizing of the lab nodes"
  default = "t3.micro"
}
