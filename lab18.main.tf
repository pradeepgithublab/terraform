provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}   
#################### Creating Instance Profile ######################

resource "aws_iam_instance_profile" "VPCFlowLog_profile" {
    name = "VPCFlowLog_Instance_profile"
    role = "${aws_iam_role.VPCFlowLog_Role.name}"
}

####################### Creating IAM Role for EC2 #######################

resource "aws_iam_role" "VPCFlowLog_Role" {
  name = "VPCFlowLog_Role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "vpc-flow-logs.amazonaws.com"
            }
        }
    ]
}
EOF
}

################### Creating IAM Role Policy ###################

resource "aws_iam_role_policy" "task110_policy" {
    name = "Ecs_role_policy"
    role = aws_iam_role.VPCFlowLog_Role.name
    
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:Describe*",
                "logs:DescribeLogStreams"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "us-east-1"
                }
            }
        }
    ]
}
EOF
}
# Create CloudWatch Logs group
resource "aws_cloudwatch_log_group" "log" {
  name = "whizvpclogs"
}   
# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}
# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "MyInternetGateway"
  }
}
# Adding route
resource "aws_route" "route" {
    route_table_id         = aws_vpc.vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}
# Create a Subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
   tags = {
    Name = "whizsub"
  }
}   
# Create a VPC Flow Logs
resource "aws_flow_log" "my_flow_log" {
  vpc_id = aws_vpc.vpc.id
  iam_role_arn     = aws_iam_role.VPCFlowLog_Role.arn
  traffic_type     = "ACCEPT"
  log_destination  = aws_cloudwatch_log_group.log.arn
  max_aggregation_interval = 60
}   
# Create Security group for EC2
resource "aws_security_group" "ec2sg" {
  name        = "whiz_sg"
  description = "whizlabssecuritygroup"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
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
    Name = "whiz_sg"
  }
}
############ Creating Key pair for EC2 ############
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "whiz_key" {
  key_name   = "nifty"
  public_key = tls_private_key.example.public_key_openssh
}
############ Launching an EC2 Instance ############
resource "aws_instance" "instance" {
    ami = "ami-02e136e904f3da870"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.ec2sg.id}"]
    subnet_id     = aws_subnet.subnet.id
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.VPCFlowLog_profile.name
    key_name = aws_key_pair.whiz_key.key_name
    tags = {
        Name = "whizlabsec2instance"
    }
    depends_on = [aws_security_group.ec2sg]
}           

