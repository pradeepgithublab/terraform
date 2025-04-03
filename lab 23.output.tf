output "launchtemplate"{
    value = aws_launch_template.whiztemp.arn            
}
output "autoscaling_group" {
    value = aws_autoscaling_group.whizgroup.arn         
}
