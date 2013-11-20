include_recipe "everything::database"

username = node["webapp"]["user"]

deploy_path = "/srv/http/#{node["webapp"]["host"]}"

user username do
  comment "website owner"
  system true
  shell "/bin/false"
end

oauth = Chef::EncryptedDataBagItem.load("webapp", "keys")["github_oauth"]

git deploy_path do
  repository "https://#{oauth}:x-oauth-basic@github.com/joelteon/joelt.io.hs.git"
  reference "deploy"
  user username
  action :checkout
  depth 1
end

template "/etc/init/webapp.conf" do
  source "webapp.conf.erb"
end

service "webapp" do
  action [:enable, :start]
end
