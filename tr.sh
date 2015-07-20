#!/bin/bash
cd /data/tran;
make html;
/bin/cp -fra /data/tran/build/html/* /data/webapps/doc/ansible/;
chown www.www /data/webapps/doc/ansible/ -R
find /data/webapps/doc/ -type f -exec  sed -i 's/fonts.googleapis.com/fonts.useso.com/g' {} \;
