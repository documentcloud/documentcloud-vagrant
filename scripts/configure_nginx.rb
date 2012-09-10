require 'fileutils'
require 'erb'
=begin
  cp config/server/nginx/nginx.conf /usr/local/nginx/conf/
  cp config/server/nginx/$RAILS_ENVIRONMENT.conf /usr/local/nginx/conf/sites-enabled/
  # TODO nginx configuration is not rock solid
  cp config/server/nginx/nginx.init /etc/init.d/nginx
  update-rc.d nginx defaults
=end

here = File.dirname(__FILE__)
rails_env = ENV['RAILS_ENV'] || "development"

File.open "/usr/local/nginx/conf/nginx.conf", "w" do |nginx_conf|
  passenger_root      = `passenger-config --root`
  nginx_conf_template = File.open(File.join(here, "erb", "nginx.conf.erb")).read
  nginx_conf.puts ERB.new(nginx_conf_template).result(binding)
end

File.open "/usr/local/nginx/conf/sites-enabled/#{rails_env}.conf", "w" do |site_conf|
  certpath = "/home/ubuntu/documentcloud/secrets/keys/dev.dcloud.org.crt"
  keypath  = "/home/ubuntu/documentcloud/secrets/keys/dev.dcloud.org.key"

  site_conf_template = File.open(File.join(here, "erb", "site.conf.erb")).read
  site_conf.puts ERB.new(site_conf_template).result(binding)
end

File.open "/usr/local/nginx/conf/documentcloud.conf", "w" do |dc_conf|
  server_name = "dev.dcloud.org"
  app_root    = "/home/ubuntu/documentcloud/public"

  dc_conf_template = File.open(File.join(here, "erb", "documentcloud.conf.erb")).read
  dc_conf.puts ERB.new(dc_conf_template).result(binding)
end
