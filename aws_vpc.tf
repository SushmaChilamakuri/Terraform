# VPC
resource "aws_vpc" "food" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "food-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "food-pub-sn" {
  vpc_id     = aws_vpc.food.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "food-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "food-pvt-sn" {
  vpc_id     = aws_vpc.food.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "food-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "food-igw" {
  vpc_id = aws_vpc.food.id

  tags = {
    Name = "food-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "food-pub-rt" {
  vpc_id = aws_vpc.food.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.food-igw.id
  }

  tags = {
    Name = "food-public-route-table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "food-pub-asc" {
  subnet_id      = aws_subnet.food-pub-sn.id
  route_table_id = aws_route_table.food-pub-rt.id
}

# Private Route Table
resource "aws_route_table" "food-pvt-rt" {
  vpc_id = aws_vpc.food.id

  tags = {
    Name = "food-private-route-table"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "food-pvt-asc" {
  subnet_id      = aws_subnet.food-pvt-sn.id
  route_table_id = aws_route_table.food-pvt-rt.id
}

# Public NACL
resource "aws_network_acl" "food-pub-nacl" {
  vpc_id = aws_vpc.food.id
  subnet_ids = [aws_subnet.food-pub-sn.id]

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
    Name = "food-public-nacl"
  }
}

# Private NACL
resource "aws_network_acl" "food-pvt-nacl" {
  vpc_id = aws_vpc.food.id
  subnet_ids = [aws_subnet.food-pvt-sn.id]

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
    Name = "food-private-nacl"
  }
}

# Public Secuirty Group
resource "aws_security_group" "food-pub-sg" {
  name        = "food-web"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.food.id

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
    Name = "food-pub-firewall"
  }
}

# Private Secuirty Group
resource "aws_security_group" "food-pvt-sg" {
  name        = "food-db"
  description = "Allow SSH & MySQL inbound traffic"
  vpc_id      = aws_vpc.food.id

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
    Name = "food-db-firewall"
  }
}
