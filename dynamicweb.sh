#!/bin/bash

#Software Installation
#  Update the server
sudo su
sudo yum update -y

# To insall Apache
sudo dnf update -y
sudo dnf list | grep httpd
sudo dnf install -y httpd.x86_64
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

# To Install PHP version 8
sudo dnf install php8.1 -y

# To Install PHP Extension
sudo yum install php php-cli php-fpm php-mysqlnd php-bcmath php-ctype php-fileinfo php-json php-mbstring php-openssl php-pdo php-gd php-tokenizer php-xml -y

# To install Mysql(Install the MySQL Community repository)
sudo sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo ls -lrt

#Install the MySQL server:
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
sudo dnf install mysql-community-server -y

#Start the MySQL server:
sudo systemctl start mysql
sudo systemctl enable mysqld
sudo mysql -V

#Enabling the PHP cURL module 
sudo yum install php-curl -y

#Restart PHP-FPM and Apache (To make the changes take effect)
sudo systemctl restart php-fpm
sudo systemctl restart httpd

# Command to change the memory limit setting to 128M  in the php.ini file 
sudo sed -i 's/^memory_limit = .*/memory_limit = 128M/' /etc/php.ini

# Restart PHP-FPM and Apache for the changes to take effect
sudo systemctl restart php-fpm
sudo systemctl restart httpd

# Command  to change the max_execution_time  in the php.ini file 
sudo sed -i 's/^max_execution_time = .*/max_execution_time = 300/' /etc/php.ini

# Restart PHP-FPM and Apache for the changes to take effect
sudo systemctl restart php-fpm
sudo systemctl restart httpd

#To Enable the 'mod_rewrite' module in Apache on an EC2 Linux instance
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf


#App Installation and Configuration

#Store app codes in an S3 bucket
sudo aws s3 sync s3://nest-webfile /var/www/html

#unzip the nest-app zip folder
cd /var/www/html
sudo unzip nest-app.zip

#move all the files and folder from the nest-app directory to the html directory
sudo mv nest-app/* /var/www/html

#move all the hidden files from the nest-app directory to the html directory
sudo mv /var/www/html/nest-app/.* /var/www/html/


#delete the nest-app and nest-app.zip folder
sudo rm -rf nest-app  nest-app.zip

#Migrate the provided SQL script into RDS database with Flyway
sudo yum update -y
wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/9.21.2/flyway-commandline-9.21.2-linux-x64.tar.gz | tar -xvz && sudo ln -s `pwd`/flyway-9.21.2/flyway /usr/local/bin 
cd flyway-9.21.2
sudo rm -rf sql
mkdir sql
aws s3 cp s3://nest-sql-webfile/V1__nest.sql /home/ec2-user/flyway-9.21.2/sql

#Migrate the provided SQL script into RDS database with Flyway
flyway  -url=jdbc:mysql://nest-rds-db2.c09fzfbzs8yo.us-east-1.rds.amazonaws.com:3306/applicationdb2\
    -user=taofeek \
    -password=rahmah2005 \
    -locations=filesystem:sql \
    migrate

#Set permissions 777 for the '/var/www/html' directory and the 'storage/
sudo chmod -R 777 /var/www/html/
sudo chmod -R 777 storage/

# Restart PHP-FPM and Apache for the changes to take effect
sudo systemctl restart php-fpm
sudo systemctl restart httpd
