#
# Cookbook Name:: continuous_delivery
# Attributes:: gitlab
#
# 2017 Aleix Penella
#

#
# gitlab configuration
default['gitlab']['config']['external_url'] = 'http://localhost'
default['gitlab']['config']['listen_port'] = 80
default['gitlab']['config']['listen_https'] = false
default['gitlab']['config']['ssh_port'] = 2222

#
# attributes for deployment node
default['gitlab']['deploy'] = { 'clear': false }

#
# directories
default['gitlab']['directory'] = {
	'/srv/gitlab/data' => {},
	'/srv/gitlab/logs' => {},
	'/srv/gitlab/config' => {}
}

#
# files required for gitlab to be configured and run
default['gitlab']['files'] = [
	{
		'file': '/srv/gitlab/config/gitlab.rb',
		'source': '#is a template and will not be created be continuous_delivery_services resource',
		'action': 'create'
	}
]

#
# systemd service definition
default['gitlab']['systemd'] = {
	'name': node['continuous_delivery']['service']['gitlab'],
	'description': 'gitlab service',
	'requires': node['continuous_delivery']['service']['docker'],
	'after': node['continuous_delivery']['service']['docker']
}

#
# docker image
default['gitlab']['docker']['image'] = {
	'name': 'gitlab/gitlab-ce',
	'tag': 'latest',
	'action': 'pull_if_missing'
}

#
# docker containers
default['gitlab']['docker']['container'] = {
	'name': 'gitlab',
	'repo': "#{node['gitlab']['docker']['image'].name}",
	'volumes': [
		"/srv/gitlab/data:/var/opt/gitlab",
		"/srv/gitlab/logs:/var/log/gitlab",
		"/srv/gitlab/config:/etc/gitlab"
	],
	'port': [
		"80:80",
		"443:443",
		"#{node['gitlab']['config']['ssh_port']}:22"
	],
	'action': 'create'
}


#
# Gitlab API
#
# auth
# default['gitlab']['auth']['user']='root'
# default['gitlab']['auth']['password']='5iveL!fe'

default['gitlab']['api']['url'] = "#{node['gitlab']['config']['external_url']}/api/v4"
default['gitlab']['api']['request'] = {
	:list_users => {
		'action': 'get',
		'url': '/users'
	},
	:create_group => {
		'action': 'post',
		'url': 'groups',
		'name': 'Newies'
	}
}