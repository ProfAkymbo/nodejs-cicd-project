variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "aws_ami" {
  description = "Amazon Linux 2 AMI"
  type        = string
  default     = "ami-098e39bafa7e7303d" #change the AMI to your specific region
}

variable "key_name" {
  description = "EC2 keypair name for SSH access"
  type        = string
}
