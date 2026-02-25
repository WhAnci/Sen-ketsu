# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "main" {
  count  = length([for k, v in var.subnets : k if v.type == "public"]) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# 서브넷
resource "aws_subnet" "main" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name = each.key
    Type = each.value.type
  }
}

# NAT 게이트웨이용 EIP
resource "aws_eip" "nat" {
  for_each = {
    for k, v in var.subnets : k => v if v.type == "public"
  }
  domain = "vpc"

  tags = {
    Name = "${each.key}-nat-eip"
  }
}

# NAT 게이트웨이
resource "aws_nat_gateway" "main" {
  for_each = {
    for k, v in var.subnets : k => v if v.type == "public"
  }
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.main[each.key].id

  tags = {
    Name = "${each.key}-nat"
  }
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "public" {
  count  = length([for k, v in var.subnets : k if v.type == "public"]) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# 프라이빗/데이터 라우팅 테이블
resource "aws_route_table" "private" {
  for_each = {
    for k, v in var.subnets : k => v if v.type != "public"
  }
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = each.value.type == "private" ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = values(aws_nat_gateway.main)[0].id
    }
  }

  tags = {
    Name = "${each.key}-rt"
  }
}

# 퍼블릭 서브넷 라우팅 연결
resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in var.subnets : k => v if v.type == "public"
  }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public[0].id
}

# 프라이빗/데이터 서브넷 라우팅 연결
resource "aws_route_table_association" "private" {
  for_each = {
    for k, v in var.subnets : k => v if v.type != "public"
  }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}