#!/bin/bash

# domain1:master_port=localhost:service_port;domain2:master_port=localhost:service_port
function create_site_config {
  site_proxies=$(echo $1 | tr ";" "\n")

  for site_proxy in $site_proxies
  do
    IFS=";"
    proxy_map=($site_proxy)
    IFS="="
    proxy_map_array=($proxy_map)
    IFS=":"
    inbound=(${proxy_map_array[0]})
    
    IFS=" "
    cat > /etc/nginx/sites-available/${inbound[0]}.conf <<EOF
server {
  listen ${inbound[1]};
  server ${inbound[0]};

  location / {
    proxypass http://${proxy_map_array[1]};
  }
}
EOF

    ln -s /etc/nginx/sites-available/${inbound[0]}.conf /etc/nginx/sites-enabled/${inbound[0]}.conf
  done
}

create_site_config $SITE_PROXIES
nginx -g 'daemon off;'