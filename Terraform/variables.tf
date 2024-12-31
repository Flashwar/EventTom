variable "region" {
  type        = string
  description = "Resource Provider: us-east-1"
  default     = "us-east-1"
  sensitive   = true
}

variable "aws_credentials" {
  type        = map(string)
  description = "AWS access key"
  sensitive   = true
}

variable "instance_type" {
  type = map(string)
  default = {
    "micro" = "t2.micro"
    "nano"  = "t2.nano"
  }
  description = "The type of EC2 instance"
}

variable "ami_ubuntu_2024LTS" {
  type    = string
  default = "ami-0866a3c8686eaeeba"
}

variable "laptop_linux_keypair" {
  type        = string
  default     = "Laptop-Linux Key Pair"
  description = "Keypair of my laptop"
}

variable "EVENTTOM_RDS_PASSWORD" {
  type = string
  sensitive = true
  description = "Password for the RDS instance"
  default = ""
}

variable "S3_BUCKET_PREFIX" {
  type = string
  default = "maxeventtom"
}

variable "SECRET_KEY_DJANGO" {
  type    = string
  default = ""
}