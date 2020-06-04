# VPC
resource "aws_vpc" "ansib-lab-vpc" {
  cidr_block            = "10.100.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  
  tags = {
    Name = "ansib-lab-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ansib-lab-gw" {
  vpc_id = aws_vpc.ansib-lab-vpc.id

  tags = {
    Name = "ansible-lab"
  }
}

# NAT Gateway / Elastic IP
resource "aws_eip" "nat-gateway-eip" {
  vpc = true
}

resource "aws_nat_gateway" "ansib-lab-nat-gw" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.ansib-lab-subnet-public.id
}

# Lab Subnets
resource "aws_subnet" "ansib-lab-subnet-public" {
  vpc_id                    = aws_vpc.ansib-lab-vpc.id
  cidr_block                = "10.100.1.0/24"
  availability_zone         = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ansib-lab-subnet-private" {
  vpc_id                    = aws_vpc.ansib-lab-vpc.id
  cidr_block                = "10.100.2.0/24"
  availability_zone         = "eu-west-1a"
}

# Route Tables
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.ansib-lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansib-lab-gw.id
  }
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.ansib-lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ansib-lab-nat-gw.id
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public-subnet-assoc" {
  route_table_id = aws_route_table.public-route.id
  subnet_id      = aws_subnet.ansib-lab-subnet-public.id
  depends_on     = [aws_route_table.public-route, aws_subnet.ansib-lab-subnet-public]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private-subnet-assoc" {
  route_table_id = aws_route_table.private-route.id
  subnet_id      = aws_subnet.ansib-lab-subnet-private.id
  depends_on     = [aws_route_table.private-route, aws_subnet.ansib-lab-subnet-private]
}

#VPC Security Group
resource "aws_security_group" "ansib-lab-sg" {
  name   = "ansib-lab-security-group"
  vpc_id = aws_vpc.ansib-lab-vpc.id

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
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}