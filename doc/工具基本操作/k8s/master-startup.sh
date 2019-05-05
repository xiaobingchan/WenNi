#!/usr/bin/env bash
setenforce 0
systemctl stop firewalld & systemctl disable firewalld
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux
swapoff -a
firewall-cmd --reload
for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler; do
systemctl restart $SERVICES
systemctl enable $SERVICES
systemctl status $SERVICES
done
