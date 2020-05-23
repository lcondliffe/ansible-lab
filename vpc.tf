# VPC and Internal lab subnet
resource "aws_vpc" "lw-lab-vpc" {
  cidr_block = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "lw-lab-vpc"
  }
}
resource "aws_subnet" "lw-lab-subnet" {
  vpc_id                    = aws_vpc.lw-lab-vpc.id
  cidr_block                = "10.100.1.0/24"
  availability_zone         = "eu-west-1a"
  map_public_ip_on_launch   = true
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

#Elastic IP and NAT Gateway
#resource "aws_nat_gateway" "lw-lab-ng" {
#  allocation_id = "${aws_eip.nat.id}"
#  subnet_id     = "${aws_subnet.lw-lab-subnet.id}"
#}


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