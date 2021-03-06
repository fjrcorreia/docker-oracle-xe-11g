#!/bin/bash

# avoid dpkg frontend dialog / frontend warnings
export DEBIAN_FRONTEND=noninteractive

cat /assets/oracle-xe_11.2.0-1.0_amd64.deba* > /assets/oracle-xe_11.2.0-1.0_amd64.deb




## Update image
apt-get update

## Required to oracle
apt-get install -y libaio1 net-tools bc

## install supervisor to lanch multiple process
#apt-get install -y supervisor

ln -s /usr/bin/awk /bin/awk
mkdir /var/lock/subsys
mv /assets/chkconfig /sbin/chkconfig
chmod 755 /sbin/chkconfig

# Install Oracle
dpkg --install /assets/oracle-xe_11.2.0-1.0_amd64.deb

# update nls_lang
sed -i "/^echo/c\echo \"${NLS_LANG}\"" /u01/app/oracle/product/11.2.0/xe/bin/nls_lang.sh


# Backup listener.ora as template
cp /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora.tmpl
cp /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora.tmpl

mv /assets/init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts
mv /assets/initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts



echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc
echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc
echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

# Install startup script for container
mv /assets/startup.sh /usr/sbin/startup.sh
chmod +x /usr/sbin/startup.sh



## Add a custom init script to run on the first time
cp  /assets/firstStartup.sql \
    /u01/app/oracle/product/11.2.0/xe/config/scripts/firstStartup.sql


## Configure supervisor
# cp  /assets/supervisord.conf    /etc/supervisor/conf.d/supervisord.conf

# Remove installation files
rm -r /assets/

exit $?
