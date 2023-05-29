resource "aws_vpc" "task-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "task_subnet1" {
  vpc_id     = aws_vpc.task-vpc.id
  cidr_block = var.subnet_cidr_block1
  tags = {
    Name = "${var.env}-subnet1"
  }
  availability_zone = var.avail_zone1
}
resource "aws_subnet" "task_subnet2" {
  vpc_id     = aws_vpc.task-vpc.id
  cidr_block = var.subnet_cidr_block2
  tags = {
    Name = "${var.env}-subnet2"
  }
  availability_zone = var.avail_zone2
}

resource "aws_internet_gateway" "task-igw" {
  vpc_id = aws_vpc.task-vpc.id
}

resource "aws_route_table" "task-route-table" {
  vpc_id = aws_vpc.task-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task-igw.id
  }
}

resource "aws_route_table_association" "task-route-table-association" {
  subnet_id      = aws_subnet.task_subnet1.id
  route_table_id = aws_route_table.task-route-table.id
}
resource "aws_route_table_association" "task-route-table-association1" {
  subnet_id      = aws_subnet.task_subnet2.id
  route_table_id = aws_route_table.task-route-table.id
}

resource "aws_security_group" "ssh-sg" {
  name        = "ssh-sg"
  description = "Allow ssh"
  vpc_id      = aws_vpc.task-vpc.id
  ingress {
    description = "allow ssh from any"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

resource "aws_security_group" "varnish-sg" {
  name   = "varnish-sg"
  vpc_id = aws_vpc.task-vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.ALB-sg.id]
    protocol        = "tcp"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

resource "aws_security_group" "ALB-sg" {
  name   = "ALB-sg"
  vpc_id = aws_vpc.task-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

resource "aws_security_group" "magento-sg" {
  name   = "magento-sg"
  vpc_id = aws_vpc.task-vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.ALB-sg.id, aws_security_group.varnish-sg.id]
    protocol        = "tcp"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}
