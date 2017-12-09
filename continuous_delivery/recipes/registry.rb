#
# Cookbook Name:: continuous_delivery
# Recipe:: registry
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
docker_image node['registry']['docker']['image'].name do
	tag node['registry']['docker']['image'].tag
	action node['registry']['docker']['image'].action
end

#
# run container
docker_container node['registry']['docker']['container'].name do
	repo 	node['registry']['docker']['container'].repo
	tag 	node['registry']['docker']['container'].tag
	port  	node['registry']['docker']['container'].port
	if node['registry']['docker']['container'].has_key?('volumes')	then volumes node['registry']['docker']['container'].volumes end
	if node['registry']['docker']['container'].has_key?('env') 	then env node['registry']['docker']['container'].env end
	action 	node['registry']['docker']['container'].action
end

#
# define systemd service
systemd_unit "#{node['registry']['service']}.service" do
	content <<-EOU.gsub(/^\s+/, '')
		[Unit]
		Description=Docker registry service
		Requires=docker.service
		After=docker.service
		[Service]
		TimeoutStartSec=0
		ExecStart=/usr/bin/docker start -a registry
		ExecStop=/usr/bin/docker stop registry
		Restart=on-failure

		[Install]
		WantedBy=multi-user.target
	EOU

	action [:create, :enable] 	
end
#
# registry service
service "#{node['registry']['service']}" do
	action :restart
end