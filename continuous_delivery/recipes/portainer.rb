#
# Cookbook Name:: continuous_delivery
# Recipe:: portainer
#
# 2017 Aleix Penella
#

if node['portainer']['clear'] then
	continuous_delivery_service "Clear #{node['portainer']['service']}" do
		image node['portainer']['docker']['image']
		container node['portainer']['docker']['container']
		systemd_service node['portainer']['systemd']
		action :clear
	end
end

continuous_delivery_service node['portainer']['service'] do
	image node['portainer']['docker']['image']
	container node['portainer']['docker']['container']
	systemd_service node['portainer']['systemd']
end

#
# pull docker image
# docker_image node['portainer']['docker']['image'].name do
# 	tag node['portainer']['docker']['image'].tag
# 	action node['portainer']['docker']['image'].action
# end


# #
# # run container
# docker_container node['portainer']['docker']['container'].name do
# 	repo 	node['portainer']['docker']['container'].repo
# 	tag 	node['portainer']['docker']['container'].tag
# 	port  	node['portainer']['docker']['container'].port
# 	if node['portainer']['docker']['container'].has_key?('volumes')	then volumes node['portainer']['docker']['container'].volumes end
# 	if node['portainer']['docker']['container'].has_key?('env') 	then env node['portainer']['docker']['container'].env end
# 	action 	node['portainer']['docker']['container'].action
# end

# #
# # create jenkins service
# systemd_unit "#{node['portainer']['service']}.service" do
# 	content <<-EOU.gsub(/^\s+/, '')
# 		[Unit]
# 		Description=Portainer service
# 		Requires=docker.service
# 		After=docker.service

# 		[Service]
# 		TimeoutStartSec=0
# 		ExecStart=/usr/bin/docker start -a portainer
# 		ExecStop=/usr/bin/docker stop portainer
# 		Restart=on-failure

# 		[Install]
# 		WantedBy=multi-user.target
# 	EOU
# 	action [:create, :enable]
# end

# #
# # restart service
# service "#{node['portainer']['service']}" do
# 	action :restart
# end