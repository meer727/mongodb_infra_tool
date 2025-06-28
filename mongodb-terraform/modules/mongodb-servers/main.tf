resource "aws_instance" "mongodb_servers" {
  count                    = length(var.private_subnet_ids)
  ami                      = var.mongodb_ami
  instance_type            = var.mongodb_instance_type
  subnet_id                = var.private_subnet_ids[count.index]
  vpc_security_group_ids   = [var.mongodb_sg_id]
  key_name                 = var.key_name
  tags = {
    Name = "mongodb-server-${count.index}"
    Role = "infra-server"
  }
}