im_version = "6.8.7-7"
im_dirname = "ImageMagick-#{im_version}"
im_filename = "#{im_dirname}.tar.gz"
im_source = "http://www.imagemagick.org/download/#{im_filename}"
im_filename_full = File.join(Chef::Config[:file_cache_path], im_filename)
im_dirname_full = File.join(Chef::Config[:file_cache_path], im_dirname)

version_test = "convert -version | grep -q #{im_version}"

remote_file im_filename_full do
  source im_source
  not_if version_test
end

directory im_dirname_full do
  not_if version_test
end

execute "unpack imagemagick" do
  command "tar xzvf #{im_filename_full} -C #{im_dirname_full} --strip-components 1"
  not_if "#{version_test} || test -f #{im_dirname_full}/configure"
end

execute "install imagemagick" do
  command <<-EOF
    cd #{im_dirname_full} && ./configure --prefix=/usr && make install
  EOF
  not_if version_test
end

file "/etc/ld.so.conf.d/imagemagick.conf" do
  content "/usr/lib"
end

execute "ldconfig" do
  command "ldconfig"
end
