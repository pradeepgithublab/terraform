provider "aws" {
region = "${var.region}"
access_key = "${var.access_key}"
secret_key = "${var.secret_key}"            
} 

################## Creating an EKS Cluster ##################
resource "aws_eks_cluster" "cluster" {
  name     = "RuhiRiaan"
  role_arn = "arn:aws:iam::176723168877:role/task98_role_234010.49584273"

  vpc_config {
    subnet_ids = ["subnet-0fd840b0788eeb0e9", "subnet-0422617823b947614"]
  }
}