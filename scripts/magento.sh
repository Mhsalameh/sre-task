#!/bin/bash


/bin/bash << 'EOF' 
sudo apt update -y && sudo apt upgrade -y &&
sudo apt install software-properties-common -y && sudo add-apt-repository ppa:ondrej/php -y &&
sudo apt update -y &&
sudo apt install php8.1-{bcmath,common,curl,fpm,gd,intl,mbstring,mysql,soap,xml,xsl,zip,cli} -y &&
sudo sed -i "s/memory_limit = .*/memory_limit = 768M/" /etc/php/8.1/fpm/php.ini &&
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/8.1/fpm/php.ini &&
sudo sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/8.1/fpm/php.ini &&
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/8.1/fpm/php.ini &&
sudo apt-get install nginx -y &&
sudo echo "upstream fastcgi_backend {
server unix:/run/php/php8.1-fpm.sock;
}

server {
    listen 80;
    server_name mhsalameh.com;
    set $MAGE_ROOT /opt/magento2;
    set $MAGE_MODE developer; # or production

    access_log /var/log/nginx/magento2-access.log;
    error_log /var/log/nginx/magento2-error.log;

    include /opt/magento2/nginx.conf.sample;
}" > magento.conf &&
sudo apt install mysql-server -y &&
sudo apt install apt-transport-https ca-certificates gnupg2 -y
sudo wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt update -y
sudo apt install elasticsearch -y
sudo fallocate -l 2G /swapfile   # Allocate a 2GB swap file
sudo chmod 600 /swapfile         # Set permissions
sudo mkswap /swapfile            # Create swap area
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo systemctl --now enable elasticsearch
sudo curl -sS https://getcomposer.org/installer -o composer-setup.php &&
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
EOF
