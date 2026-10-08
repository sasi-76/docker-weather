output "ec2_public_ip" {
  description = "Public IP address of the Weather Dashboard EC2 instance"
  value       = aws_instance.weather_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the Weather Dashboard EC2 instance"
  value       = aws_instance.weather_server.public_dns
}

output "weather_url" {
  description = "URL of the Weather Dashboard"
  value       = "http://${aws_instance.weather_server.public_ip}"
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.weather_server.id
}
