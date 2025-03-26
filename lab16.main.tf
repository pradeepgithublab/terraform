provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}
#Creating a security group    
resource "aws_security_group" "rds_sg01" {      
  name = "rds_sg01"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
   ingress {  
    from_port   = 22    
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Creating RDS Database Instance
resource "aws_db_instance" "myinstance" {
  engine               = "mysql"
  identifier           = "mydatabaseinstance"
  allocated_storage    =  20
  engine_version       = "8.0.32"
  instance_class       = "db.t3.medium"
  username             = "asadmin"
  password             = "asapassword"
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = ["${aws_security_group.rds_sg01.id}"]
  skip_final_snapshot  = true
  publicly_accessible =  true   
}
resource "aws_instance" "web-server" {
    ami = "ami-02e136e904f3da870"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.rds_sg01.name}"]
    user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install mysql -y
    EOF
    tags = {
        Name = "whiz_instance"  
    }     
}
