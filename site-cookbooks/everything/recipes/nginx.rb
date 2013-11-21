include_recipe "everything::certs"

execute "install nginx" do
  command "rpm -i http://nginx.org/packages/rhel/6/x86_64/RPMS/nginx-1.4.4-1.el6.ngx.x86_64.rpm"
  not_if "test -x /usr/sbin/nginx"
end

nginx_root = "/etc/nginx"

directory nginx_root do
  action :delete
  recursive true
  only_if "test -d #{nginx_root}/conf.d"
end

directory nginx_root

%w{
  conf
  sites-available
  sites-enabled
}.each do |dir|
  directory "#{nginx_root}/#{dir}" do
    recursive true
  end
end

%w{
  nginx.conf
  mime.types
  conf/cross-domain-fonts.conf
  conf/expires.conf
  conf/h5bp.conf
  conf/x-ua-compatible.conf
  conf/protect-system-files.conf
}.each do |f|
  template "#{nginx_root}/#{f}" do
    source "#{f}.erb"
  end
end

template "/etc/nginx/sites-available/webapp" do
  source "sites/webapp.erb"
  variables({
    :host => node["webapp"]["host"],
    :other_hosts => node["webapp"]["other_hosts"],
    :upload_root => site_root(node["webapp"]["host"]) + "/uploads",
    :cert_file => node["webapp"]["cert_path"],
    :key_file => node["webapp"]["key_path"],
    :proxy_port => 6000
  })
end

template "/etc/nginx/sites-available/webapp-oauth" do
  source "sites/webapp-oauth.erb"
  variables({
    :host => node["webapp"]["oauth_host"],
    :cert_file => node["webapp"]["cert_path"],
    :key_file => node["webapp"]["key_path"],
    :proxy_port => 6000
  })
end

template "/etc/nginx/sites-available/webapp-static" do
  source "sites/webapp-static.erb"
  variables({
    :host => node["webapp"]["static_host"],
    :cert_file => node["webapp"]["cert_path"],
    :key_file => node["webapp"]["key_path"],
    :static_root => site_root(node["webapp"]["host"]) + "/static"
  })
end

%w{webapp webapp-oauth webapp-static}.each do |src|
  link "/etc/nginx/sites-enabled/#{src}" do
    to "/etc/nginx/sites-available/#{src}"
  end
end

execute "test nginx config" do
  command "/usr/sbin/nginx -t"
end

template "/etc/init/nginx.conf" do
  source "init/nginx.conf.erb"
end

service "nginx" do
  action [:enable, :start]
  provider Chef::Provider::Service::Upstart
end
