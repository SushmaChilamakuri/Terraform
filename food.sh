#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo yum -y install git
sudo rm -rf /var/www/html/*
sudo git clone https://github.com/ravi2krishna/food.git /var/www/html
