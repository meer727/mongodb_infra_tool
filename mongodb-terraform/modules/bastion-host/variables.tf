variable "public_subnet_id" {
  description = "ID of the public subnet where the bastion host will be created"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

variable "bastion_ami" {
  description = "AMI ID for the bastion host"
  type        = string
  default     = "ami-0ec1bf4a8f92e7bd1" # (Oregon) 
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}
variable "key_name" {
  description = "Name of the SSH key pair to use for the bastion host"
  type        = string
}