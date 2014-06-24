# Ensure nginx is installed
test -e /usr/local/nginx || (gem install passenger && /usr/local/bin/passenger-install-nginx-module --auto --auto-download \
    --prefix /usr/local/nginx --extra-configure-flags='--with-http_gzip_static_module --with-http_ssl_module --with-http_stub_status_module')

LINE='export PATH=$PATH:/usr/local/nginx/sbin'
grep -q "$LINE" .bashrc 2>/dev/null || echo "$LINE" >> .bashrc

mkdir -p /usr/local/nginx/conf/sites-enabled /var/log/nginx/
mkdir -p /var/log/nginx

ruby /vagrant/scripts/configure_nginx.rb

cp /home/vagrant/documentcloud/config/server/files/nginx/nginx.init /etc/init.d/nginx
update-rc.d nginx defaults
/etc/init.d/nginx start
