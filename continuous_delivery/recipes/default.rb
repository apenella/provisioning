#
# Cookbook Name:: continuous_delivery
# Recipe:: default
#
# 2017 Aleix Penella
#

include_recipe 'continuous_delivery::docker'
include_recipe 'continuous_delivery::registry'
include_recipe 'continuous_delivery::gitlab'
include_recipe 'continuous_delivery::jenkins'
include_recipe 'continuous_delivery::users'
#include_recipe 'continuous_delivery::test'

# include portainer service
if node['continuous_delivery']['service']['portainer'] then 
	include_recipe 'continuous_delivery::portainer' 
end

# include registry-ui service
if node['continuous_delivery']['service']['registry_ui'] then 
	include_recipe 'continuous_delivery::registry_ui' 
end
