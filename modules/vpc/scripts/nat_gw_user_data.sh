#!/bin/bash

sudo yum install iptables iptables-services -y
sudo systemctl enable --now iptables
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo bash -c 'echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/20-ip-forward.conf'
sudo bash -c ' echo "" > /etc/sysconfig/iptables'
sudo systemctl restart iptables
sudo iptables -t nat -A POSTROUTING -o ens5 -s 0.0.0.0/0 -j MASQUERADE
sudo bash -c 'iptables-save > /etc/sysconfig/iptables'