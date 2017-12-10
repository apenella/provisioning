#
# Cookbook Name:: continuous_delivery
# Recipe:: jenkins
#
# 2017 Aleix Penella
#

#
# System configuration

#
# create directories 
node['jenkins']['directory'].each do |d, info|
	directory d do
		recursive true
		action :create
	end
end


#
# Jenkins data

#
# clear service
if node['jenkins']['deploy']['jenkins-data']['clear'] then
	continuous_delivery_service "Clear jenkins-data" do
		files node['jenkins']['clear']['jenkins-data'].files
		image node['jenkins']['docker']['image']['jenkins-data']
		container node['jenkins']['docker']['container']['jenkins-data']
		action :clear
	end
end

#
# import dockerfiles for jenkins data building
cookbook_file node['jenkins']['docker']['image']['jenkins-data'].build do
	source node['jenkins']['docker']['image']['jenkins-data'].orig
	action :create
end

#
# deploy service
continuous_delivery_service node['jenkins']['docker']['image']['jenkins-data'].name do
	image node['jenkins']['docker']['image']['jenkins-data']
	container node['jenkins']['docker']['container']['jenkins-data']
end

#
# JENKINS MASTER
#===============================

#
# import dockerfiles for jenkins-master
cookbook_file node['jenkins']['docker']['image']['jenkins-master'].build do
  source node['jenkins']['docker']['image']['jenkins-master'].orig
  action :create
end

#
# build docker image for jenkins master
docker_image node['jenkins']['docker']['image']['jenkins-master'].name do
	source node['jenkins']['docker']['image']['jenkins-master'].source
	action node['jenkins']['docker']['image']['jenkins-master'].action
end

#
# create contaniner jenkins-master
docker_container node['jenkins']['docker']['container']['jenkins-master'].name do
	repo 					node['jenkins']['docker']['container']['jenkins-master'].repo
	volumes_from 	node['jenkins']['docker']['container']['jenkins-master'].volumes_from
	port  				node['jenkins']['docker']['container']['jenkins-master'].port
	volumes 			node['jenkins']['docker']['container']['jenkins-master'].volumes
	action 				node['jenkins']['docker']['container']['jenkins-master'].action
end

#
# create jenkins service
systemd_unit "#{node['jenkins']['service']}.service" do
	content <<-EOU.gsub(/^\s+/, '')
		[Unit]
		Description=jenkins service
		Requires=docker.service
		After=docker.service

		[Service]
		TimeoutStartSec=0
		ExecStart=/usr/bin/docker start -a jenkins-master
		ExecStop=/usr/bin/docker stop jenkins-master
		Restart=on-failure

		[Install]
		WantedBy=multi-user.target
	EOU
	action [:create, :enable]
end

#
# copying jenkins configuration file that excludes security
cookbook_file node['jenkins']['config']['file'].name do
  source node['jenkins']['config']['file'].source
  action node['jenkins']['config']['file'].action
  notifies :run, "execute[#{node['jenkins']['config']['file'].execute}]", :immediately
end

#
# modify jenkins configuration to exclude securtiy
execute node['jenkins']['config']['file'].execute do
	command 'docker cp /tmp/config.xml jenkins-master:/var/jenkins_home/config.xml'
  cwd '/tmp'
  action :nothing
end

#
# jenkins-master service
service "#{node['jenkins']['service']}" do
	action :restart
end

#
# copying jenkins' setup script. This script allows container to manage the docker engine from host.
cookbook_file node['jenkins']['config']['setup'].script do
  source 	node['jenkins']['config']['setup'].source
  mode 		node['jenkins']['config']['setup'].mode
  action 	node['jenkins']['config']['setup'].action
  notifies :run, 'execute[jenkins_master_setup.sh]', :immediately
end

#
# execute script to setup jenkins.
execute 'jenkins_master_setup.sh' do
	command '/tmp/jenkins_master_setup.sh'
  cwd 		'/tmp'
  action :nothing
end

#
# jenkins-master service
service "#{node['jenkins']['service']}" do
	action :restart
end