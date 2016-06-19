#!/bin/bash

# Updating repository

echo "Updating repos..."
sudo apt-get -y update

# Installing Apache

echo "Installing Apache2..."
sudo apt-get -y install apache2

# Installing MySQL and it's dependencies, Also, setting up root password for MySQL as it will prompt to enter the password during installation

echo "Setting MySQL variables; installing MySQL and dependencies..."
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password mypass'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password mypass'
sudo apt-get -y install mysql-server libapache2-mod-auth-mysql php5-mysql

# Installing PHP and it's dependencies

echo "Installing PHP and its dependencies..."
sudo apt-get -y install php5 libapache2-mod-php5 php5-mcrypt

# Create necessary Apache directories, then restart Apache

echo "Creating Apache directories, then restarting Apache..."
if [ ! -h /var/www ]; 
then 
    mkdir /vagrant/public
    rm -rf /var/www 
    ln -s /vagrant/public /var/www
    a2enmod rewrite
    sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
    service apache2 restart
fi
 
# Grab the latest version of WordPress, extract & move it, then delete archive

echo "Grabbing the latest version of WordPress and installing..."
if [ ! -d /vagrant/public/wp-admin ];
then
    cd /vagrant/public
    wget http://wordpress.org/latest.tar.gz  
    tar xvf latest.tar.gz 
    mv wordpress/* ./  
    rmdir ./wordpress/  
    rm -f latest.tar.gz
fi
 
# Create MySQL databases (if they haven't been created already)

echo "Creating MySQL databases..."
if [ ! -f /var/log/databasesetup ];
then
    mysql -u root -pmypass -e "CREATE DATABASE wordpress;"
    mysql -u root -pmypass -e "CREATE USER 'mywpuser'@'localhost' IDENTIFIED BY 'mywppass';"
    mysql -u root -pmypass -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'mywpuser'@'localhost';"
    mysql -u root -pmypass -e "FLUSH PRIVILEGES;"
    touch /var/log/databasesetup
fi
