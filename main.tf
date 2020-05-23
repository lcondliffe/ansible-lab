# Configure the AWS Provider
provider "aws" {
  version = "2.7"
  region  = "eu-west-1"

  #Export AWS Credentials as environment vars:
  # export AWS_ACCESS_KEY_ID="anaccesskey"
  # export AWS_SECRET_ACCESS_KEY="asecretkey"
}

# VPC and Subnet
resource "aws_vpc" "lw-lab-vpc" {
  cidr_block = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "lw-lab-vpc"
  }
}
resource "aws_subnet" "lw-lab-subnet" {
  vpc_id = aws_vpc.lw-lab-vpc.id
  cidr_block = "10.100.1.0/24"
  availability_zone = "eu-west-1a"
}

# Internet Gateway and Route Table
resource "aws_internet_gateway" "lw-lab-gw" {
  vpc_id = aws_vpc.lw-lab-vpc.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "lw-lab-rt" {
  vpc_id = aws_vpc.lw-lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lw-lab-gw.id
  }
}
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.lw-lab-vpc.id
  route_table_id = aws_route_table.lw-lab-rt.id
}


#VPC Security Group
resource "aws_security_group" "lw-lab-sg" {
  name   = "lw-lab-security-group"
  vpc_id = aws_vpc.lw-lab-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    self        = true
  }
  
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Gather Ubuntu 18.04 Latest AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create 3 Ubuntu 18.04 Instances
resource "aws_instance" "lw-lab-nodes" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.lw-lab-subnet.id
  vpc_security_group_ids      = [aws_security_group.lw-lab-sg.id]
  

  tags = {
    Name  = "lw-lab-0${count.index + 1}"
    Env   = "lab"
  }

  key_name = "lw"
}

# Create Bastion Host
resource "aws_instance" "lw-lab-bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.lw-lab-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.lw-lab-sg.id]

  tags = {
    Name = "lw-lab-bst"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      #"sudo apt-get install python3-pip -y",
      "sudo apt install python-pip -y",
      "pip install boto3",
    ]

      connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/luke/.ssh/lw.pem")
      host        = self.public_ip
    }
  }

  provisioner "file"{
    source      = "/home/luke/.ssh/lw.pem"
    destination = "/home/ubuntu/.ssh/lw.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/luke/.ssh/lw.pem")
      host        = self.public_ip
    }
  }
  
  provisioner "file"{
    source      = "aws_ec2.yml"
    destination = "/home/ubuntu/aws_ec2.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/luke/.ssh/lw.pem")
      host        = self.public_ip
    }
  }

  provisioner "file"{
    source      = "ansible.cfg"
    destination = "/home/ubuntu/ansible.cfg"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/luke/.ssh/lw.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/ansible.cfg /etc/ansible/ansible.cfg",
      "chmod 700 /home/ubuntu/.ssh/lw.pem",
    ]

      connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/luke/.ssh/lw.pem")
      host        = self.public_ip
    }
  }

  key_name = "lw"
}