#
# Cookbook Name:: continuous_delivery
# Recipe:: registry_ui
#
# 2017 Aleix Penella
#

#
# clear service
if node['registry_ui']['deploy']['clear'] then
	continuous_delivery_service "Clear #{node['registry_ui']['service']}" do
		image node['registry_ui']['docker']['image']
		container node['registry_ui']['docker']['container']
		systemd_service node['registry_ui']['systemd']
		action :clear
	end
end

#
# deploy service
continuous_delivery_service node['registry_ui']['service'] do
	image node['registry_ui']['docker']['image']
	container node['registry_ui']['docker']['container']
	systemd_service node['registry_ui']['systemd']
end
