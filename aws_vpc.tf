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
