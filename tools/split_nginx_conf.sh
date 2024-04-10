#!/bin/bash
mkdir -p /tmp/sites-miab
MIAB_NGINX_CONF="/etc/nginx/conf.d/local.conf"
cd  /tmp/sites-miab
rm -f *.conf
csplit "$MIAB_NGINX_CONF" '/^\s*server\s*{*$/' {*}
for i in xx*; do
  new=$(grep -oPm1 '(?<=server_name).+(?=;)' $i|sed -e 's/\(\w\) /\1_/g'|xargs);
  if [[ -e $new.conf ]] ; then
    echo "" >>$new.conf
    cat "$i">>$new.conf
    rm "$i"
  else
    mv "$i" $new.conf
  fi
done
## Only Transfer really changed files. 
rsync rsync -hvrP --checksum --delete /tmp/sites-miab /etc/nginx
