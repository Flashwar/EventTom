output "load_balancer_arn" {
  description = "ARN of the Load Balancer"
  value       = aws_lb.eventtom_backend_alb.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = aws_lb.eventtom_backend_alb.dns_name
}

output "public_ip" {
  description = "Public IP Address for the Public IP"
  value       = "http://${aws_instance.eventtom_ec2.public_ip}"
}

# output "uploaded_files" {
#   description = "Uploaded files to S3 bucket"
#   value       = aws_s3_object.static_website_files[*].key
# }