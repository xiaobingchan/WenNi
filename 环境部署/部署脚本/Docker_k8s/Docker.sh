#!/usr/bin/env bash
uname -a   # 查看内核版本
yum update # yum更新源
yum install -y yum-utils device-mapper-persistent-data lvm2  # 安装依赖包
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo  # 设置yum源
yum-config-manager --enable docker-ce-edge
yum-config-manager --enable docker-ce-test
yum-config-manager --disable docker-ce-edge
yum list docker-ce --showduplicates | sort -r # 搜索docker版本
yum install docker-ce-18.06.3.ce   # yum安装特定版本的docker
systemctl start docker  # 启动docker服务
systemctl enable docker # 添加开机启动
