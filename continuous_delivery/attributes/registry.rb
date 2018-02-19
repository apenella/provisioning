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
default['registry']['systemd'] = {
	'name': node['continuous_delivery']['service']['registry'],
	'description': 'Service for private docker registry',
	'requires': node['continuous_delivery']['service']['docker'],
	'after': node['continuous_delivery']['service']['docker']
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
	'name': "#{node['continuous_delivery']['service']['registry']}",
	'repo': "#{node['registry']['docker']['image'].name}",
	'tag': "#{node['registry']['docker']['image'].tag}",
	'port': "5000:#{node['registry']['config']['port']}",
	'env': [
		"REGISTRY_STORAGE_DELETE_ENABLED=true"
	],
	'action': 'create'
}