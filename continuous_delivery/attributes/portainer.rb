#
# Cookbook Name:: continuous_delivery
# Attributes:: portainer
#
# 2017 Aleix Penella
#

#
# attributes for deployment node
default['portainer']['deploy']['clear'] = false

#
# systemd service definition
default['portainer']['service'] = 'portainer'
default['portainer']['systemd'] = {
	'name': node['portainer']['service'],
	'description': 'Portainer service manages docker host or swarm cluster',
	'requires': node['docker']['service'],
	'after': node['docker']['service']
}

#
# service configuration
default['portainer']['config']['port'] = 9000

#
# docker images
default['portainer']['docker']['image'] = {
	'name': 'portainer/portainer',
	'tag': 'latest',
	'action': 'pull_if_missing'
}

#
# docker containers
default['portainer']['docker']['container'] = {
	'name': 'portainer',
	'repo': "#{node['portainer']['docker']['image'].name}",
	'tag': "#{node['portainer']['docker']['image'].tag}",
	'port': "#{node['portainer']['config']['port']}:#{node['portainer']['config']['port']}",
	'volumes': '/var/run/docker.sock:/var/run/docker.sock',
	'action': 'run_if_missing'
}