#
# Cookbook Name:: continuous_delivery
# Recipe:: jenkins
#
# 2017 Aleix Penella
#

#
# System configuration
#

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

#
# clear service
if node['jenkins']['deploy']['jenkins-data']['clear'] then
	continuous_delivery_service "Clear #{node['jenkins']['docker']['image']['jenkins-data'].name}" do
		image node['jenkins']['docker']['image']['jenkins-data']
		container node['jenkins']['docker']['container']['jenkins-data']
		files node['jenkins']['files']['jenkins-data']
		action :clear
	end
end

#
# deploy service
continuous_delivery_service node['jenkins']['docker']['image']['jenkins-data'].name do
	image node['jenkins']['docker']['image']['jenkins-data']
	container node['jenkins']['docker']['container']['jenkins-data']
	files node['jenkins']['files']['jenkins-data']
end

#
# Jenkins master
#

#
# clear service
if node['jenkins']['deploy']['jenkins-master']['clear'] then
	continuous_delivery_service "Clear #{node['jenkins']['systemd'].name}" do
		image node['jenkins']['docker']['image']['jenkins-master']
		container node['jenkins']['docker']['container']['jenkins-master']
		files node['jenkins']['files']['jenkins-master']
		systemd_service node['jenkins']['systemd']
		action :clear
	end
end

#
# deploy service
continuous_delivery_service node['jenkins']['systemd'].name do
	image node['jenkins']['docker']['image']['jenkins-master']
	container node['jenkins']['docker']['container']['jenkins-master']
	files node['jenkins']['files']['jenkins-master']
	systemd_service node['jenkins']['systemd']
end

#
# modify jenkins configuration to exclude securtiy
execute 'copy config.xml' do
	command 'docker cp /srv/docker/jenkins-master/config.xml jenkins-master:/var/jenkins_home/config.xml'
	cwd '/srv/docker/jenkins-master'
	action :run
end

#
# execute script to setup jenkins.
execute 'execute script jenkins_master_setup.sh' do
	command '/srv/docker/jenkins-master/jenkins_master_setup.sh'
	cwd '/srv/docker/jenkins-master'
	action :run
end

#
# jenkins-master service
service node['jenkins']['systemd'].name do
	action :restart
end