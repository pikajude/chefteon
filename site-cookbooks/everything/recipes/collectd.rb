package "perl-ExtUtils-MakeMaker"

user "collectd" do
  comment "collectd user"
  system true
  shell "/bin/false"
end

collectd_file = "#{Chef::Config[:file_cache_path]}/collectd.tar.gz"
collectd_dir = "#{Chef::Config[:file_cache_path]}/collectd"

remote_file collectd_file do
  source "http://collectd.org/files/collectd-5.4.0.tar.gz"
  not_if "test -x /opt/collectd/sbin/collectd"
end

directory collectd_dir

execute "build collectd" do
  command <<-EOF
    tar xzvf #{collectd_file} -C #{collectd_dir} --strip-components 1
    cd #{collectd_dir} && ./configure && make install
  EOF
  not_if "test -x /opt/collectd/sbin/collectd"
end
