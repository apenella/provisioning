#
# Cookbook Name:: continuous_delivery
# Attributes:: registry
#
# 2017 Aleix Penella
#

#
# attributes for deployment node
default['registry']['deploy']['clear'] = false

#
# systemd service definition
default['registry']['service'] = 'registry'
default['registry']['systemd'] = {
	'name': node['registry']['service'],
	'description': 'Service for private docker registry',
	'requires': node['docker']['service'],
	'after': node['docker']['service']
}

#
# registry configuration
default['registry']['config']['host'] = '0.0.0.0'
default['registry']['config']['port'] = 5000
default['registry']['config']['protocol'] = 'http'
default['registry']['config']['addr'] = "#{node['registry']['config']['host']}:#{node['registry']['config']['port']}"
default['registry']['config']['storage'] = "/var/lib/registry"

#
# docker images
default['registry']['docker']['image'] = {
	'name': 'registry',
	'tag': '2',
	'action': 'pull_if_missing'
}

#
# docker containers
default['registry']['docker']['container'] = {
	'name': "#{node['registry']['service']}",
	'repo': "#{node['registry']['docker']['image'].name}",
	'tag': "#{node['registry']['docker']['image'].tag}",
	'port': "5000:#{node['registry']['config']['port']}",
	'env': [
		"REGISTRY_HOST=#{node['registry']['config']['host']}",
		"REGISTRY_STORAGE_DELETE_ENABLED=true"
	],
	'action': 'create'
}