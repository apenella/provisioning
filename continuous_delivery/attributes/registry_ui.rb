#
# Cookbook Name:: continuous_delivery
# Attributes:: registry_ui
#
# 2017 Aleix Penella
#

#
# attributes for deployment node
default['registry_ui']['deploy']['clear'] = false

#
# systemd service definition
default['registry_ui']['service'] = 'registry-ui'
default['registry_ui']['systemd'] = {
	'name': node['registry_ui']['service'],
	'description': 'Registry UI service gives to user a way to manage its private docker registry',
	'requires': node['registry']['service'],
	'after': node['registry']['service']
}

#
# service configuration
default['registry_ui']['config']['registry'] = '0.0.0.0:5000'

#
# docker image
default['registry_ui']['docker']['image'] = {
	'name': 'parabuzzle/docker-registry-ui',
	'tag': 'latest',
	'action': 'pull_if_missing'
}

#
# docker containers
default['registry_ui']['docker']['container'] = {
	'name': 'registry-ui',
	'repo': "#{node['registry_ui']['docker']['image'].name}",
	'tag': "#{node['registry_ui']['docker']['image'].tag}",
	'port': '5080:80',
	'env': [
		"REGISTRY_HOST=#{node['registry']['config']['host']}", 
		"REGISTRY_PORT=#{node['registry']['config']['port']}", 
		"REGISTRY_PROTOCOL=#{node['registry']['config']['protocol']}"
	],
	'action': 'create'
}