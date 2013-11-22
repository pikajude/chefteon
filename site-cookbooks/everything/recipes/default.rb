#
# Cookbook Name:: chefteon
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "chef_handler"

chef_gem "chef-handler-elapsed-time"
require 'chef/handler/elapsed_time'

chef_handler "Chef::Handler::ElapsedTime" do
  source "chef/handler/elapsed_time"
  action :nothing
end.run_action(:enable)

include_recipe "everything::webapp"
include_recipe "everything::znc"
include_recipe "everything::collectd"
