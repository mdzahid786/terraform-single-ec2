output "instance_public_ip" {
    description = "Public IP of the EC2 instance"
    value = aws_instance.app_server.public_ip
}


output "instance_public_dns" {
    description = "Public DNS name"
    value = aws_instance.app_server.public_dns
}