#!/bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
git clone https://$TOKEN@github.com/ompayat/capstone.git
cd /home/ubuntu/capstone
apt install python3-pip -y
apt-get install python3.10-dev default-libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/capstone/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations     #Run only once (When you test userdata on test instance, not add on launch template)
python3 manage.py migrate            #Run only once (When you test userdata on test instance, not add on launch template)
python3 manage.py runserver 0.0.0.0:80
