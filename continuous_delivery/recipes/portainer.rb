#
# Cookbook Name:: continuous_delivery
# Recipe:: portainer
#
# 2017 Aleix Penella
#

#
# clear service
if node['portainer']['deploy']['clear'] then
	continuous_delivery_service "Clear #{node['portainer']['service']}" do
		image node['portainer']['docker']['image']
		container node['portainer']['docker']['container']
		systemd_service node['portainer']['systemd']
		action :clear
	end
end

#
# deploy service
continuous_delivery_service node['portainer']['service'] do
	image node['portainer']['docker']['image']
	container node['portainer']['docker']['container']
	systemd_service node['portainer']['systemd']
end