#!/bin/bash
LISTENER_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
TNSNAMES_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora

cp "${LISTENER_ORA}.tmpl" "$LISTENER_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENER_ORA}" &&
sed -i "s/%port%/1521/g" "${LISTENER_ORA}" &&
cp "${TNSNAMES_ORA}.tmpl" "$TNSNAMES_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${TNSNAMES_ORA}" &&
sed -i "s/%port%/1521/g" "${TNSNAMES_ORA}" &&

if [ -e "/etc/default/oracle-xe" ]; then
    service oracle-xe start
else
    ## Delaing configuration to the last moment to reduce image size
    printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

    ## make sure it is not running
    /etc/init.d/oracle-xe stop

    ## Switch scripts
    cp  /u01/app/oracle/product/11.2.0/xe/config/scripts/startdb.sql \
        /u01/app/oracle/product/11.2.0/xe/config/scripts/startdb.sql.tmp
    cp  /u01/app/oracle/product/11.2.0/xe/config/scripts/firstStartup.sql \
        /u01/app/oracle/product/11.2.0/xe/config/scripts/startdb.sql

    ## start oracle with modified init script
    /etc/init.d/oracle-xe start

    ## restore init script
    mv /u01/app/oracle/product/11.2.0/xe/config/scripts/startdb.sql.tmp \
       /u01/app/oracle/product/11.2.0/xe/config/scripts/startdb.sql

fi

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE

if [ "$ORACLE_ALLOW_REMOTE" = true ]; then
  echo "alter system disable restricted session;" | sqlplus -s SYSTEM/oracle
fi



if [ ! -e "/docker-entrypoint-initdb.d/.configured" ]; then
    for f in /docker-entrypoint-initdb.d/*; do
      case "$f" in
        *.sh)     echo "$0: running $f"; /bin/bash -c "$f" ;;
        *.sql)    echo "$0: running $f"; echo "exit" | /u01/app/oracle/product/11.2.0/xe/bin/sqlplus "SYSTEM/oracle" @"$f"; echo ;;
        *)        echo "$0: ignoring $f" ;;
      esac
      echo
    done
    if [ -e "/docker-entrypoint-initdb.d" ]; then
        touch /docker-entrypoint-initdb.d/.configured
    fi
fi


exec /usr/bin/tail -F /u01/app/oracle/diag/tnslsnr/${HOSTNAME}/listener/trace/listener.log
