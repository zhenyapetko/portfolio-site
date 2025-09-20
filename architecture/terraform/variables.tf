variable "ami_id" {
  description = "Ubuntu 24.04 AMI ID"
  type        = string
  default     = "ami-0360c520857e3138f"  
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "security_group_ports" {
  description = "Ports для security group"
  type        = list(number)
  default     = [22, 80, 443]
}