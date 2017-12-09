#
# Cookbook Name:: continuous_delivery
# Recipe:: jenkins
#
# 2017 Aleix Penella
#


#
# CLEAR
#===============================
if node['jenkins']['clear']['files'].do then
	# delete each file
	node['jenkins']['clear']['files'].list.each do |f|
		file f do
			action :delete
		end
	end
end

if node['jenkins']['clear']['images'].do then
	#TODO	
end

if node['jenkins']['clear']['containers'].do then
	# stop container
	service "jenkins:clear:containers stopping service #{node['jenkins']['service']}" do
		service_name "#{node['jenkins']['service']}"
		action :stop
	end

	# delete containers
	node['jenkins']['clear']['containers'].list.each do |c|
		docker_container "jenkins:clear:containers delete container #{c}" do
			container_name c
			remove_volumes true
			action :delete
		end
	end	
end


#
# SYSTEM CONFIGURATION
#===============================

#
# create directories 
node['jenkins']['directory'].each do |d, info|
	directory d do
		recursive true
		action :create
	end
end

#
# JENKINS DATA
#===============================

#
# import dockerfiles for jenkins data
cookbook_file node['jenkins']['docker']['image']['jenkins-data'].build do
  source node['jenkins']['docker']['image']['jenkins-data'].orig
  action :create
end

#
# build docker images for jenkins-data
docker_image node['jenkins']['docker']['image']['jenkins-data'].name do
  source node['jenkins']['docker']['image']['jenkins-data'].source
  action node['jenkins']['docker']['image']['jenkins-data'].action
end

#
# create contaniner jenkins-data
docker_container node['jenkins']['docker']['container']['jenkins-data'].name do
	repo 		node['jenkins']['docker']['container']['jenkins-data'].repo
  action 	node['jenkins']['docker']['container']['jenkins-data'].action
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

#
# install jenkins plugins
# node['jenkins']['plugins'].each do |p|
# 	execute "#{p}" do
# 		command "docker exec jenkins-master java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin #{p} -restart"
# 		not_if "docker exec jenkins-master java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080 list-plugins | grep -i #{p}"
# 		timeout 300
# 	end
# end