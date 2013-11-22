package "perl-ExtUtils-MakeMaker"

user "collectd" do
  comment "collectd user"
  system true
  shell "/bin/false"
end

remote_file "#{Chef::Config[:file_cache_path]}/collectd.tar.gz" do
  source "http://collectd.org/files/collectd-5.4.0.tar.gz"
  not_if "test -x /usr/sbin/collectd"
end

directory "#{Chef::Config[:file_cache_path]}/collectd"

execute "install collectd" do
  command <<-EOF
    tar xzvf #{Chef::Config[:file_cache_path]}/collectd.tar.gz -C #{Chef::Config[:file_cache_path]}/collectd --strip-components 1
    cd #{Chef::Config[:file_cache_path]}/collectd && ./configure && make install
  EOF
  not_if "test -x /usr/sbin/collectd"
end

template "/etc/init/collectd.conf" do
  source "init/collectd.conf.erb"
  variables({
    :user => node['collectd']['user']
  })
end

service "collectd" do
  action [:enable, :start]
  provider Chef::Provider::Service::Upstart
end
