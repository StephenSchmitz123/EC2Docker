
# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "EC2-Docker-VPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "vpc_public_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "EC2DockerPublicSubnet"
  }
}

# Create Route Table
resource "aws_route_table" "ebs_vpc_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "EC2DockerRouteTable"
  }
}

# Create Route for Internet
resource "aws_route" "public_internet_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.ebs_vpc_route_table.id
  gateway_id = aws_internet_gateway.igw.id
}

# Create Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.vpc_public_subnet.id
  route_table_id = aws_route_table.ebs_vpc_route_table.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "EC2DockerInternetGateway"
  }
}