variable "private_subnet_ids" {
  description = "List of private subnet IDs where Mongodb servers will be created"
  type        = list(string)
}

variable "mongodb_sg_id" {
  description = "Security group ID for Mongodb servers"
  type        = string
}

variable "mongodb_ami" {
  description = "AMI ID for Mongodb servers"
  type        = string
  default     = "ami-0ec1bf4a8f92e7bd1" #(oregon)
}

variable "mongodb_instance_type" {
  description = "Instance type for Mongodb servers"
  type        = string
  default     = "t2.micro"
}
variable "key_name" {
  description = "Name of the SSH key pair to use for Mongodb servers"
  type        = string
}