# CONFIGURATION AND PARAMETERS CHANGE AMIN ID AND KEY NAME 

provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

# Create a VPC
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.vpc.id
}

# Create a Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
}

# Create a Route for Public Route Table
resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gateway.id
}

# Get available AWS Availability Zones
data "aws_availability_zones" "available" {}

# Create a Public Subnet
resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = element(data.aws_availability_zones.available.names, 0)
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# Create a Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id
}

# Create a Private Subnet
resource "aws_subnet" "private" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = element(data.aws_availability_zones.available.names, 0)
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

# Create a Security Group for EC2 Instance
resource "aws_security_group" "instance_sg" {
    vpc_id = aws_vpc.vpc.id

    # Allow SSH access
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow HTTP access
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create an EC2 Instance in the Public Subnet
resource "aws_instance" "public_instance" {
    ami           = "ami-08b5b3a93ed654d19"  # Update with a valid Linux AMI ID
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.public.id
   security_group_ids = [aws_security_group.instance_sg.id]  # Use security group ID instead of name
    key_name      = "holi"  # Update with your SSH key name
    tags = {
        Name = "Public-EC2"
    }
}
