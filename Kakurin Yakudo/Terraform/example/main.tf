module "vpc" {
  source = "./modules/01_vpc"

  vpc_name = "sen-ketsu-dev-vpc"  # VPC 이름 직접 지정
  vpc_cidr = "10.0.0.0/16"

  # 서브넷 이름도 직접 지정
  subnets = {
    "web-public-2a" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-northeast-2a"
      type             = "public"
    }
    "web-public-2c" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-northeast-2c"
      type             = "public"
    }
    "app-private-2a" = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "ap-northeast-2a"
      type             = "private"
    }
    "app-private-2c" = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "ap-northeast-2c"
      type             = "private"
    }
    "db-data-2a" = {
      cidr_block        = "10.0.21.0/24"
      availability_zone = "ap-northeast-2a"
      type             = "data"
    }
    "db-data-2c" = {
      cidr_block        = "10.0.22.0/24"
      availability_zone = "ap-northeast-2c"
      type             = "data"
    }
  }
}

# VPC Peering (주석 해제하여 사용)
# resource "aws_vpc_peering_connection" "main" {
#   vpc_id      = module.vpc.vpc_id          # 요청자 VPC (현재 VPC)
#   peer_vpc_id = "vpc-xxxxxxxx"             # 수락자 VPC (피어링할 대상 VPC)
#   auto_accept = true                       # 같은 계정/리전이면 자동 수락
# 
#   tags = {
#     Name = "sen-ketsu-peering"
#   }
# }
# 
# # 요청자 VPC 라우팅 (현재 VPC → 대상 VPC)
# resource "aws_route" "requester_route" {
#   route_table_id            = "rtb-xxxxxxxx"  # 현재 VPC 라우팅 테이블 ID
#   destination_cidr_block    = "10.1.0.0/16"  # 대상 VPC CIDR
#   vpc_peering_connection_id = aws_vpc_peering_connection.main.id
# }
# 
# # 수락자 VPC 라우팅 (대상 VPC → 현재 VPC) - 필요시 추가
# resource "aws_route" "accepter_route" {
#   route_table_id            = "rtb-yyyyyyyy"  # 대상 VPC 라우팅 테이블 ID
#   destination_cidr_block    = "10.0.0.0/16"  # 현재 VPC CIDR
#   vpc_peering_connection_id = aws_vpc_peering_connection.main.id
# }

# Bastion Host
module "bastion" {
  source = "./modules/02_bastion"

  bastion_name         = "sen-ketsu-bastion"           # Bastion 이름
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.subnet_ids["web-public-2a"]  # 퍼블릭 서브넷
  instance_type       = "t3.micro"                    # 인스턴스 타입
  key_name            = "my-keypair"                  # 키페어 이름
  ssh_port            = 22                            # SSH 포트 (변경 가능)
  allowed_cidr_blocks = ["0.0.0.0/0"]                # 접근 허용 IP (보안상 특정 IP로 변경 권장)
  volume_size         = 20                            # 루트 볼륨 크기 (GB)
}
