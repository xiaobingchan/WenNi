#!/usr/bin/env bash

mkdir -p /usr/local/gitea
cd /usr/local/gitea
wget -O gitea https://dl.gitea.io/gitea/1.8.2/gitea-1.8.2-linux-amd64
chmod +x gitea
yum -y install git
nohup ./gitea web &

create database gitea DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

http://118.89.23.220:3000
