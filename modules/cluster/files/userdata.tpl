#!/bin/bash
hostnamectl set-hostname "${hostname}"
subscription-manager register --username=${username} --password=${password}
subscription-manager refresh
subscription-manager attach --pool=${pool_id}
yum-config-manager --disable \*
subscription-manager repos \
  --enable="rhel-7-server-rpms" \
  --enable="rhel-7-server-extras-rpms" \
  --enable="rhel-7-server-ose-3.11-rpms" \
  --enable="rhel-7-server-ansible-2.6-rpms"
yum -y install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
yum -y install docker-1.13.1
yum -y update
#hostnamectl set-hostname "orig_hostname"
reboot