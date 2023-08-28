Hosting a Dynamic Website on Ec2 in AWS Cloud
Software Installation
Update Server
bash
Copy code
sudo yum update -y
Install Apache
bash
Copy code
sudo dnf update -y
sudo dnf list | grep httpd
sudo dnf install -y httpd.x86_64
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
Install PHP version 8
bash
Copy code
sudo dnf install php8.1 -y
Install PHP Extensions
bash
Copy code
sudo yum install php php-cli php-fpm php-mysqlnd php-bcmath php-ctype php-fileinfo php-json php-mbstring php-openssl php-pdo php-gd php-tokenizer php-xml -y
Install MySQL and Start Server
bash
Copy code
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
sudo dnf install mysql-community-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld
Enable PHP cURL Module
bash
Copy code
sudo yum install php-curl -y
Change PHP Memory Limit
bash
Copy code
sudo sed -i 's/^memory_limit = .*/memory_limit = 128M/' /etc/php.ini
sudo systemctl restart php-fpm
sudo systemctl restart httpd
Change max_execution_time
bash
Copy code
sudo sed -i 's/^max_execution_time = .*/max_execution_time = 300/' /etc/php.ini
sudo systemctl restart php-fpm
sudo systemctl restart httpd
Enable 'mod_rewrite' module in Apache
bash
Copy code
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
App Installation and Configuration
Store App Codes in an S3 Bucket
bash
Copy code
sudo aws s3 sync s3://nest-webfile /var/www/html
Unzip and Move App Files
bash
Copy code
cd /var/www/html
sudo unzip nest-app.zip
sudo mv nest-app/* /var/www/html
sudo mv /var/www/html/nest-app/.* /var/www/html/
Delete Unused Folders
bash
Copy code
sudo rm -rf nest-app nest-app.zip
Migrate SQL Script into RDS Database with Flyway
bash
Copy code
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
Set Permissions
bash
Copy code
sudo chmod -R 777 /var/www/html/
sudo chmod -R 777 storage/
sudo systemctl restart php-fpm
sudo systemctl restart httpd
This README provides step-by-step instructions for deploying and configuring your application. It covers software installation, web server setup, app deployment, and database migration. Make sure to replace placeholders with actual values specific to your environment.
