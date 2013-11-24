user "znc" do
  comment "znc user"
  system true
  shell "/bin/false"
end

znc_file = "#{Chef::Config[:file_cache_path]}/znc.tar.gz"
znc_dir = "#{Chef::Config[:file_cache_path]}/znc"
znc_home = "/var/lib/znc"

remote_file znc_file do
  source "http://znc.in/releases/znc-1.2.tar.gz"
  not_if "test -x /usr/bin/znc"
end

directory znc_dir

execute "build znc" do
  command <<-EOF
    tar xzvf #{znc_file} -C #{znc_dir} --strip-components 1
    cd #{znc_dir} && ./configure --prefix=/usr && make install
  EOF
  not_if "test -x /usr/bin/znc"
end

directory "#{znc_home}/configs" do
  recursive true
  owner "znc"
end

keys = Chef::EncryptedDataBagItem.load("znc", "auth")
pass = keys["pass"]
salt = keys["salt"]

irc_data = Chef::EncryptedDataBagItem.load("znc", "passwords")
irc_data["passwords"].each do |network, pas|
  node.default['znc']['networks'][network]['password'] = pas
end
irc_data["nickserv"].each do |network, ns|
  node.default['znc']['networks'][network]['nickserv'] = ns
end

template "#{znc_home}/configs/znc.conf" do
  source "znc.conf.erb"
  variables({
    :port => node['znc']['port'],
    :allow_ssl => node['znc']['allow_ssl'],
    :user => node['znc']['user'],
    :password => {
      :salt => salt,
      :hash => Digest::SHA256.hexdigest(pass + salt)
    },
    :networks => node['znc']['networks']
  })
  owner "znc"
end

template "/etc/init/znc.conf" do
  source "init/znc.conf.erb"
end

service "znc" do
  action [:enable, :start]
  provider Chef::Provider::Service::Upstart
end
