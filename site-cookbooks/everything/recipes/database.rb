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

package "postgresql93-server"
package "postgresql93-devel"

execute "init database" do
  command "service postgresql-9.3 initdb"
  not_if "test -d /var/lib/pgsql/9.3/data/base"
end

db_user = node['webapp']['database']['user']
db_name = node['webapp']['database']['name']
db_pass = Chef::EncryptedDataBagItem.load("webapp", "keys")["database"]

template "/var/lib/pgsql/9.3/data/pg_hba.conf" do
  source "pg_hba.conf.erb"
  variables({
    :db_user => db_user,
    :db_name => db_name
  })
end

service "postgresql-9.3" do
  action [:enable, :start]
end

execute "add webapp database user" do
  user "postgres"
  command <<-EOF
    psql -c #{Shellwords.escape "create user \"#{db_user}\" with password '#{db_pass}'"}
  EOF
  not_if <<-EOF
    sudo -u postgres psql -tAc #{Shellwords.escape "select 1 from pg_roles where rolname='#{db_user}'"} | grep -q 1
  EOF
end

execute "add webapp database table" do
  user "postgres"
  command <<-EOF
    psql -c #{Shellwords.escape "create database \"#{db_name}\" owner \"#{db_user}\""}
  EOF
  not_if <<-EOF
    sudo -u postgres psql -tAc #{Shellwords.escape "select 1 from pg_database where datname='#{db_name}'"} | grep -q 1
  EOF
end
