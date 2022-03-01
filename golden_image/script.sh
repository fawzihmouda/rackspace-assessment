#!/bin/bash
sudo yum -y update
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
sudo yum -y install httpd
sudo chkconfig httpd on
sudo service httpd start
echo 'This is version AMI v2' > version.txt