class Chef::Recipe
  include Everything
end

require 'shellwords'

rpm = value_for_platform_family(
  ["rhel", "fedora", "suse"] => ["http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm", "pgdg-centos93"]
)

execute "add postgres RPM" do
  command <<-EOF
    rpm -i #{Shellwords.escape rpm[0]}
  EOF
  not_if "rpm -qa | grep #{Shellwords.escape rpm[1]}"
end

package "postgresql93-devel"

include_recipe "everything::imagemagick"
include_recipe "everything::nginx"

username = node["webapp"]["user"]

deploy_path = site_root(node["webapp"]["host"])

user username do
  comment "website owner"
  system true
  shell "/bin/false"
end

directory "/srv/http" do
  recursive true
end

directory deploy_path do
  owner username
end

directory "/var/log/webapp" do
  owner username
end

oauth = Chef::EncryptedDataBagItem.load("webapp", "keys")["github_oauth"]

git deploy_path do
  repository "https://#{oauth}:x-oauth-basic@github.com/joelteon/joelt.io-deploy.git"
  reference "master"
  user username
  depth 1
end

execute "unzip binary" do
  command "rm -f webapp && gunzip < webapp.gz > webapp && chmod +x webapp"
  cwd "#{deploy_path}/dist/build/webapp"
  notifies :restart, "service[webapp]"
  notifies :restart, "service[nginx]"
end

template "/etc/init/webapp.conf" do
  source "init/webapp.conf.erb"
  variables({
    :root => deploy_path,
    :user => username
  })
end

service "webapp" do
  action [:enable, :start]
  provider Chef::Provider::Service::Upstart
end
