Hosting a Dynamic Website on Ec2 in AWS Cloud


#Software Installation

#Update Server

#!/bin/bash

sudo su
sudo yum update -y

#Install Apache

sudo dnf update -y

sudo dnf list | grep httpd

sudo dnf install -y httpd.x86_64

sudo systemctl start httpd.service

sudo systemctl enable httpd.service

#Install PHP version 8

sudo dnf install php8.1 -y

Install PHP Extensions



sudo yum install php php-cli php-fpm php-mysqlnd php-bcmath php-ctype php-fileinfo php-json php-mbstring php-openssl php-pdo php-gd php-tokenizer php-xml -y

#Install MySQL and Start Server

sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y

sudo dnf install mysql-community-server -y

sudo systemctl start mysqld

sudo systemctl enable mysqld

#Enable PHP cURL Module

sudo yum install php-curl -y

Change PHP Memory Limit

sudo sed -i 's/^memory_limit = .*/memory_limit = 128M/' /etc/php.ini

sudo systemctl restart php-fpm

sudo systemctl restart httpd

#Change max_execution_time

sudo sed -i 's/^max_execution_time = .*/max_execution_time = 300/' /etc/php.ini

sudo systemctl restart php-fpm

sudo systemctl restart httpd

#Enable 'mod_rewrite' module in Apache

sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

#App Installation and Configuration

#Store App Codes in an S3 Bucket

sudo aws s3 sync s3://nest-webfile /var/www/html

#Unzip and Move App Files

cd /var/www/html

sudo unzip nest-app.zip

sudo mv nest-app/* /var/www/html

sudo mv /var/www/html/nest-app/.* /var/www/html/

#Delete Unused Folders

sudo rm -rf nest-app nest-app.zip

#Migrate SQL Script into RDS Database with Flyway

sudo yum update -y

wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/9.21.2/flyway-commandline-9.21.2-linux-x64.tar.gz | tar -xvz && sudo ln -s `pwd`/flyway-9.21.2/flyway /usr/local/bin 

cd flyway-9.21.2

sudo rm -rf sql

mkdir sql

aws s3 cp s3://nest-sql-webfile/V1__nest.sql /home/ec2-user/flyway-9.21.2/sql

flyway  -url=jdbc:mysql://nest-rds-db2.c09fzfbzs8yo.us-east-1.rds.amazonaws.com:3306/applicationdb2 \

    -user=taofeek \
    
    -password=rahmah2005 \
    
    -locations=filesystem:sql \

    migrate
    
#Set Permissions

sudo chmod -R 777 /var/www/html/

sudo chmod -R 777 storage/

# Edit the '.env' file located in the html directory and add the followed values for your domain name and database credentials:

sed -i 's|^APP_URL=.*|APP_URL=https://www.zabithon.com|' /var/www/html/.env
sed -i 's|^DB_HOST=.*|DB_HOST=nest-rds-db.c09fzfbzs8yo.us-east-1.rds.amazonaws.com|' /var/www/html/.env
sed -i 's|^DB_DATABASE=.*|DB_DATABASE=applicationdb|' /var/www/html/.env
sed -i 's|^DB_USERNAME=.*|DB_USERNAME=taofeek|' /var/www/html/.env
sed -i 's|^DB_PASSWORD=.*|DB_PASSWORD=rahmah2005|' /var/www/html/.env

#Open the 'AppServiceProvider.php' file in the '/var/www/html/app/Providers' directory and add the following code in the public function boot():

sed -i '/public function boot()/a \\ \\\ \\\ if (env("APP_ENV") === "production") {\\Illuminate\\Support\\Facades\\URL::forceScheme("https");\\}' /var/www/html/app/Providers/AppServiceProvider.php

sudo systemctl restart php-fpm

sudo systemctl restart httpd

This README provides step-by-step instructions for deploying and configuring your application. It covers software installation, web server setup, app deployment, and database migration. Make sure to replace placeholders with actual values specific to your environment.
