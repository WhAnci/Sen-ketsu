#!/bin/bash
yum update -y

# SSH 포트 변경 (주석 해제하여 사용)
# sed -i 's/#Port 22/Port ${ssh_port}/' /etc/ssh/sshd_config
# systemctl restart sshd

# 추가 설정이 필요하면 여기에 작성