provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

# Create the Lambda function
resource "aws_lambda_function" "test_lambda" {
    filename         = "lambda_function.zip"
    function_name    = "firstlambda"
    role             = "arn:aws:iam::934542352265:role/Lambda_role"
    handler          = "lambda_function.lambda_handler"
    runtime          = "python3.8"
    source_code_hash = filebase64sha256("lambda_function.zip")
}
## Creating Rest APi
resource "aws_api_gateway_rest_api" "testAPI" {
    name        = "WhizAPI"
    description = "This is my API for demonstration purposes"
   endpoint_configuration {
      types     = ["REGIONAL"]       
   }
}
resource "aws_api_gateway_resource" "testresource" {
    parent_id   = aws_api_gateway_rest_api.testAPI.root_resource_id
    path_part   = "whizapi"
    rest_api_id = aws_api_gateway_rest_api.testAPI.id           
}
resource "aws_api_gateway_method" "testMethod" {
    rest_api_id   = aws_api_gateway_rest_api.testAPI.id
    resource_id   = aws_api_gateway_resource.testresource.id
    http_method   = "GET"
    authorization = "NONE"           
}
resource "aws_api_gateway_method_response" "response_200" {
    rest_api_id = aws_api_gateway_rest_api.testAPI.id
    resource_id = aws_api_gateway_resource.testresource.id
    http_method = aws_api_gateway_method.testMethod.http_method
    status_code = "200"
    response_models = {
         "application/json" = "Empty"        
     }           
}
resource "aws_api_gateway_integration" "MyDemoIntegration" {
    rest_api_id          = aws_api_gateway_rest_api.testAPI.id
    resource_id          = aws_api_gateway_resource.testresource.id
    http_method          = aws_api_gateway_method.testMethod.http_method
    integration_http_method     = "POST"
     uri = aws_lambda_function.test_lambda.invoke_arn
    type                 = "AWS"
    passthrough_behavior    = "WHEN_NO_TEMPLATES"           
}  
# Integration response for the API
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
    rest_api_id        = aws_api_gateway_rest_api.testAPI.id
    resource_id        = aws_api_gateway_resource.testresource.id
    http_method        = aws_api_gateway_method.testMethod.http_method
    status_code        = aws_api_gateway_method_response.response_200.status_code
    response_templates = { "application/json" = "" }
    depends_on         = [aws_api_gateway_integration.MyDemoIntegration]
}
resource "aws_api_gateway_deployment" "testdep" {
    rest_api_id = aws_api_gateway_rest_api.testAPI.id
    triggers = {
      redeployment = sha1(jsonencode([
        aws_api_gateway_resource.testresource.id,
        aws_api_gateway_method.testMethod.id,
        aws_api_gateway_integration.MyDemoIntegration.id,     
      ]))         
    }
    depends_on = [aws_api_gateway_integration.MyDemoIntegration]
    lifecycle {
      create_before_destroy = true         
    }           
}
resource "aws_api_gateway_stage" "teststage" {
    deployment_id = aws_api_gateway_deployment.testdep.id
     rest_api_id   = aws_api_gateway_rest_api.testAPI.id
      stage_name    = "whizstage"         
}
resource "aws_lambda_permission" "api_gw" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.test_lambda.function_name}"
    principal     = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.testAPI.execution_arn}/*/*"           
}
