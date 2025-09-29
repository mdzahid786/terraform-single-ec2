variable "region" {
    description = "AWS region"
    type = string
    default = "ap-south-1"
}


variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t2.micro"
}

variable "key_name" {
    description = "Name for the SSH key pair to be created (uses public_key_path)"
    type = string
    default = "deployer-key"
}

variable "public_key_path" {
    description = "Path to your public SSH key file (openssh format)"
    type = string
    default = "~/.ssh/id_ed25519.pub"
}

variable "tags" {
    description = "Tags for resources"
    type = map(string)
    default = { Name = "flask-express-ec2" }
}