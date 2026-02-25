# Bastion용 Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-sg"
  description = "Security group for Bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "Custom SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 필요 시 제한 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

# IAM Role for Full AWS Access
resource "aws_iam_role" "bastion_role" {
  name = "wsk-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "wsk-admin-role"
  }
}

# Attach AdministratorAccess Policy
resource "aws_iam_role_policy_attachment" "bastion_admin" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Instance Profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "wsk-admin-profile"
  role = aws_iam_role.bastion_role.name
}

# Elastic IP
resource "aws_eip" "bastion_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-eip"
  }
}

# EC2 Instance (Amazon Linux 2023, ARM 기반)
resource "aws_instance" "bastion" {
  ami                    = "ami-0092e0c93f74c293a"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_pair_name
  user_data              = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = var.name
  }
}

# Elastic IP Association
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}