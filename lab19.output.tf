output "api_invoke_url" {
    value = "${aws_api_gateway_stage.teststage.invoke_url}/${aws_api_gateway_resource.testresource.path_part}"           
   }