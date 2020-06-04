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
resource "aws_instance" "ansib-lab-nodes" {
  count                   = 3
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.node_instance_size
  subnet_id               = aws_subnet.ansib-lab-subnet-private.id
  vpc_security_group_ids  = [aws_security_group.ansib-lab-sg.id]
  

  tags = {
    Name  = "ansib-lab-0${count.index + 1}"
    Env   = "lab"
  }

  key_name = var.ssh_key_name
}

# Create Bastion Host (Ubuntu 18.04)
resource "aws_instance" "ansib-lab-bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_size
  subnet_id                   = aws_subnet.ansib-lab-subnet-public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ansib-lab-sg.id]

  tags = {
    Name = "ansib-lab-bst"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install software-properties-common -y",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "sudo apt install python-pip -y",
      "pip install boto3",
    ]

      connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  provisioner "file"{
    source      = "ansible/"
    destination = "/home/ubuntu"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

    provisioner "file"{
    source      = var.ssh_key
    destination = "/home/ubuntu/.ssh/key.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }
  
  provisioner "file"{
    source      = "aws_ec2.yml"
    destination = "/home/ubuntu/aws_ec2.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  provisioner "file"{
    source      = "ansible.cfg"
    destination = "/home/ubuntu/ansible.cfg"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/ansible.cfg /etc/ansible/ansible.cfg",
      "chmod 700 /home/ubuntu/.ssh/key.pem",
    ]

      connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  key_name = var.ssh_key_name
}