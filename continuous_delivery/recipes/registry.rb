#
# Cookbook Name:: continuous_delivery
# Recipe:: registry
#
# 2017 Aleix Penella
#

#
# clear service
if node['registry']['deploy']['clear'] then
	continuous_delivery_service "Clear #{node['registry']['service']}" do
		image node['registry']['docker']['image']
		container node['registry']['docker']['container']
		systemd_service node['registry']['systemd']
		action :clear
	end
end

#
# deploy service
continuous_delivery_service node['registry']['service'] do
	image node['registry']['docker']['image']
	container node['registry']['docker']['container']
	systemd_service node['registry']['systemd']
end