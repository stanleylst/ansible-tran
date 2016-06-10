#!/bin/bash
cd /data/tran;
make html;
/bin/cp -fra /data/tran/build/html/* /data/webapps/doc/ansible/;
chown www.www /data/webapps/doc/ansible/ -R
find /data/webapps/doc/ -type f -exec  sed -i 's/fonts.googleapis.com/fonts.useso.com/g' {} \;


sed -i s@'View page source'@'马哥Linux团队荣誉出品'@g `grep "View page source" -rl /data/webapps/doc/ansible/`
sed -i s@_sources/index.txt@http://www.magedu.com@g /data/webapps/doc/ansible/index.html
#find /data/webapps/doc/ -type f -exec  sed -i 's/View page source/马哥Linux团队成员荣誉出品/g' {} \;
