#
# Cookbook Name:: continuous_delivery
# Attributes:: docker
#
# 2017 Aleix Penella
#

#
#
# Docker configuration
# default['docker']['service'] = 'docker'

#default['docker']['config']['group'] = 'docker'
default['docker']['config']['directory'] = '/etc/docker'
default['docker']['config']['daemon'] = '/etc/docker/daemon.json'
default['docker']['config']['registry'] = [
	{
		'insecure': true,
		'registry': "#{node['registry']['config']['host']}:#{node['registry']['config']['port']}"
	}
]
default['docker']['package']['name'] = 'docker-ce'
default['docker']['package']['version'] = '17.09.0'