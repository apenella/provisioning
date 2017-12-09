#
# Cookbook Name:: continuous_delivery
# Attributes:: gitlab
#
# 2017 Aleix Penella
#

# system
default['gitlab']['directory'] = {
	'/srv/gitlab/data' => {},
	'/srv/gitlab/logs' => {},
	'/srv/gitlab/config' => {}
}

default['gitlab']['service'] = {
	'name': 'gitlab',
	'start': "docker start #{default['gitlab']['docker']['container'].name}",
	'stop': "docker stop #{default['gitlab']['docker']['container'].name}",
	'restart': "docker restart #{default['gitlab']['docker']['container'].name}"
}

# docker
default['gitlab']['docker']['image'] = {
	'name':  'gitlab/gitlab-ce'
}

default['gitlab']['docker']['container'] = {
	'name': 'gitlab',
	'repo': 'gitlab/gitlab-ce',
	'volumes': ["/srv/gitlab/data:/var/opt/gitlab","/srv/gitlab/logs:/var/log/gitlab","/srv/gitlab/config:/etc/gitlab"],
	'port': ["80:80","443:443","2222:22"]
}

# gitlab configuration
default['gitlab']['config']['external_url'] = 'http://localhost'
default['gitlab']['config']['listen_port'] = 80
default['gitlab']['config']['listen_https'] = false

# auth
default['gitlab']['auth']['user']='root'
default['gitlab']['auth']['password']='5iveL!fe'
default['gitlab']['auth']['access_token']="LJqYdnGDxSx-DuxXEhPH"

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