#
# Cookbook Name:: continuous_delivery
# Recipe:: registry_ui
#
# 2017 Aleix Penella
#

# clear systemd service
#
# systemctl stop [servicename]
# systemctl disable [servicename]
# rm /etc/systemd/system/[servicename]
# rm /etc/systemd/system/[servicename] symlinks that might be related
# systemctl daemon-reload
# systemctl reset-failed

#
# pull docker image
docker_image node['registry_ui']['docker']['image'].name do
	tag node['registry_ui']['docker']['image'].tag
	action node['registry_ui']['docker']['image'].action
end

#
# run container
docker_container node['registry_ui']['docker']['container'].name do
	repo 	node['registry_ui']['docker']['container'].repo
	tag 	node['registry_ui']['docker']['container'].tag
	port  	node['registry_ui']['docker']['container'].port
	if node['registry_ui']['docker']['container'].has_key?('volumes')	then volumes node['registry_ui']['docker']['container'].volumes end
	if node['registry_ui']['docker']['container'].has_key?('env') 	then env node['registry_ui']['docker']['container'].env end
	action 	node['registry_ui']['docker']['container'].action
end

#
# define systemd service
systemd_unit "#{node['registry_ui']['service']}.service" do
	content <<-EOU.gsub(/^\s+/, '')
		[Unit]
		Description=Registry-ui service
		Requires=registry.service
		After=registry.service
		[Service]
		TimeoutStartSec=0
		ExecStart=/usr/bin/docker start -a registry-ui
		ExecStop=/usr/bin/docker stop registry-ui
		Restart=on-failure

		[Install]
		WantedBy=multi-user.target
	EOU

	action [:create, :enable] 	
end

#
# registry-ui service
service "#{node['registry_ui']['service']}" do
	action :restart
end