# Amazon Linux 2023 최신 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# IAM Role
resource "aws_iam_role" "bastion" {
  name = "${var.bastion_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Administrator 권한 연결
resource "aws_iam_role_policy_attachment" "bastion_admin" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Instance Profile
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.bastion_name}-profile"
  role = aws_iam_role.bastion.name
}

# Security Group
resource "aws_security_group" "bastion" {
  name   = "${var.bastion_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.bastion_name}-sg"
  }
}

# EIP
resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "${var.bastion_name}-eip"
  }
}

# EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    ssh_port = var.ssh_port
  })

  tags = {
    Name = var.bastion_name
  }
}

# EIP 연결
resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}