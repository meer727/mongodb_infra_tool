resource "aws_instance" "bastion_host" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name # Add this line
  tags = {
    Name = "Bastion-host"
    Role = "Bastion-server"
  }
}