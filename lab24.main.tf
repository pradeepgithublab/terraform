provider "aws" {
region = "${var.region}"
access_key = "${var.access_key}"
secret_key = "${var.secret_key}"            
} 
#Create a Lambda Function
resource "aws_lambda_function" "lambda" {
filename = "whiz_lambda_function.zip"
function_name = "myEC2LambdaFunction"
role = "arn:aws:iam::755342539140:role/myrole-234010.67639432"
handler = "lambda_function.lambda_handler"
timeout = 6
runtime = "python3.8"
source_code_hash = filebase64("whiz_lambda_function.zip")           
}
