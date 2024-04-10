#!/bin/bash
# should get executed with | grep "\." until we got something better to suppress the numbers
mkdir -p /tmp/sites-miab
cd  /tmp/sites-miab
rm -f *.conf xx*
MIAB_NGINX_CONF="/etc/nginx/miab.conf"
csplit "$MIAB_NGINX_CONF" '/^\s*server\s*{*$/' {*}
mkdir -p /etc/nginx/miab-ssl-conf.d
for i in xx*; do
  new=$(grep -oPm1 '(?<=server_name).+(?=;)' $i|sed -e 's/\(\w\) /\1_/g'|xargs);
  if [[ -e /etc/nginx/conf.d/$new.conf ]] ; then
    echo "Ignoring Custom Config $new"
    cat "$i" | grep "ssl_certificate" > "/etc/nginx/miab-ssl-conf.d/$new.conf"
    rm "$i"
  else
      echo "Updating/Creating $new"
      if [[ -e $new.conf ]] ; then
        echo "" >>$new.conf
        cat "$i">>$new.conf      
        rm "$i"
      else
        mv "$i" $new.conf
      fi
      cat "$new.conf" | grep "ssl_certificate" > "/etc/nginx/miab-ssl-conf.d/$new.conf"
  fi
done
## Only Transfer really changed files. 
rsync -hvrP --checksum --delete /tmp/sites-miab /etc/nginx
