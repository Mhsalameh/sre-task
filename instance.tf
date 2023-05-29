data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}

resource "aws_key_pair" "deploy-key" {
  key_name   = "deploy-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoi4ql/xoWv7WOVIZ5JWBtTimh8hKoZZUWMgvoUpl5/klhC5VnkCSDXBHwBz7svslN2QqlS4GxrJTMuwOXW3Y+/NlP7VWXOiZETuQPQQsTSmPj+enu+QAdf6Ho6gHO2j4RQAGhgTvPR4uDt6A12afeTmEE9FP3/Bq9/20o1+oNoUaed/19RdQgNtBnAGKL9LK4VayeGdLLOhldvjpWDHFtRkGkZyHdl70/s6Hj3GzYOE+UTDmF0pkr1Grw4X598iCVuqOIxc/o+YJ5MHxN8tXXzMwcrtMdGg4rSGKTqRci8naneMSUfOW3HbTFHkobGSrPbKtT2AH4YBO+y8tFYzuKN2EOCZMJwGe1k1ymfwvjEUtJm0x/QaIkZ08dMKIiMegGfbMt4oFJz/kinDodwSA1WXPSqaxDMDdWBJTttR3wLH/z1abmq7pdlonuq/9gvbyt/u7ONl/4nzSgfREkd03pLGmWBb4yWfTqRuz0ZiVq8Zocvyy9gHF+4DXT/HDiGxU= mohsalameh1@gmail.com"
}

resource "aws_instance" "varnich_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.task_subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh-sg.id, aws_security_group.varnish-sg.id]
  key_name                    = aws_key_pair.deploy-key.key_name
  tags = {
    Name = "varnich_instance"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    private_key = file(var.private_key_file)
    user        = var.remote_user
  }

  provisioner "remote-exec" {
    script = "./scripts/varnish.sh"
  }
}

resource "aws_instance" "magento-instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.task_subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh-sg.id, aws_security_group.magento-sg.id]
  key_name                    = aws_key_pair.deploy-key.id
  tags = {
    Name = "magento-instance"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    private_key = file(var.private_key_file)
    user        = var.remote_user
  }

  provisioner "remote-exec" {
    script = "./scripts/magento.sh"
  }
}
