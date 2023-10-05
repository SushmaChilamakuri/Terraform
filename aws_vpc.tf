# VPC
resource "aws_vpc" "ecomm" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecomm-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "ecomm-pub-sn" {
  vpc_id     = aws_vpc.ecomm.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "ecomm-pvt-sn" {
  vpc_id     = aws_vpc.ecomm.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ecomm-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "ecomm-pub-rt" {
  vpc_id = aws_vpc.ecomm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-public-route-table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "ecomm-pub-asc" {
  subnet_id      = aws_subnet.ecomm-pub-sn.id
  route_table_id = aws_route_table.ecomm-pub-rt.id
}

# Private Route Table
resource "aws_route_table" "ecomm-pvt-rt" {
  vpc_id = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-private-route-table"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "ecomm-pvt-asc" {
  subnet_id      = aws_subnet.ecomm-pvt-sn.id
  route_table_id = aws_route_table.ecomm-pvt-rt.id
}

# Public NACL
resource "aws_network_acl" "ecomm-pub-nacl" {
  vpc_id = aws_vpc.ecomm.id
  subnet_ids = [aws_subnet.ecomm-pub-sn.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ecomm-public-nacl"
  }
}

# Private NACL
resource "aws_network_acl" "ecomm-pvt-nacl" {
  vpc_id = aws_vpc.ecomm.id
  subnet_ids = [aws_subnet.ecomm-pvt-sn.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ecomm-private-nacl"
  }
}

# Public Secuirty Group
resource "aws_security_group" "ecomm-pub-sg" {
  name        = "ecomm-web"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.ecomm.id

  ingress {
    description      = "SSH from WWW"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP from WWW"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecomm-pub-firewall"
  }
}

# Private Secuirty Group
resource "aws_security_group" "ecomm-pvt-sg" {
  name        = "ecomm-db"
  description = "Allow SSH & MySQL inbound traffic"
  vpc_id      = aws_vpc.ecomm.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }
  ingress {
    description      = "MYSQL from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecomm-db-firewall"
  }
}
