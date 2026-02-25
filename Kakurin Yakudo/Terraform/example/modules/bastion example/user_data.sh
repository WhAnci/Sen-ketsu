#!/bin/bash
# port 변경
sed -i 's/#Port 22/Port 2202/g' /etc/ssh/sshd_config
systemctl restart sshd
