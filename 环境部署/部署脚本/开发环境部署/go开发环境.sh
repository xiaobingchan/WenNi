#!/usr/bin/env bash
wget https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz
tar -xzvf go1.12.5.linux-amd64.tar.gz -C /usr/local/
mkdir -p /home/gopath
cat >> /etc/profile <<EOF
export GOROOT=/usr/local/go
export GOPATH=/home/gopath
export PATH=\$PATH:\$GOROOT/bin
EOF
source /etc/profile
go version
