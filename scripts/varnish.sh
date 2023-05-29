#!/bin/bash
/bin/bash << 'EOF'
sudo apt-get update -y
sudo apt install curl gnupg apt-transport-https -y
sudo curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | sudo apt-key add -
echo "deb https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ focal main" | sudo tee -a /etc/apt/sources.list.d/varnish60lts.list
sudo apt update -y
sudo apt install varnish -y
EOF