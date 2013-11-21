module Everything
  def site_root name
    File.join("/srv", "http", name)
  end
end

class Chef::Resource::Template
  include Everything
end
