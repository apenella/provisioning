#
# Cookbook Name:: continuous_delivery
# Attributes:: jenkins
#
# 2017 Aleix Penella
#

#
# attributes for deployment node
default['jenkins']['deploy'] = {
	'jenkins-data' => { 'clear': false },
	'jenkins-master' => { 'clear': false }
}

#
# directories
default['jenkins']['base_dir'] = '/srv/jenkins'
default['jenkins']['jenkins-data_dir'] = '/srv/docker/jenkins-data'
default['jenkins']['jenkins-master_dir'] = '/srv/docker/jenkins-master'

default['jenkins']['directory'] = {
	default['jenkins']['jenkins-data_dir'] => {},
	default['jenkins']['jenkins-master_dir'] => {},
	default['jenkins']['base_dir'] => {}
}

#
# files that must been copied to server
default['jenkins']['files'] = {
	'jenkins-data' => [
		{
			'file': '/srv/docker/jenkins-data/Dockerfile',
			'source': 'jenkins/jenkins-data/Dockerfile',
			'action': 'create'
		}
	],
	'jenkins-master' => [
		{
			'file': '/srv/docker/jenkins-master/config.xml',
			'source': 'jenkins/config.xml',
			'action': 'create'
		},
		{
			'file': '/srv/docker/jenkins-master/jenkins_master_setup.sh',
			'source': 'jenkins/jenkins_master_setup.sh',
			'mode': '0755',
			'action': 'create'
		},
		{
			'file': '/srv/docker/jenkins-master/Dockerfile',
			'source': 'jenkins/jenkins-master/Dockerfile',
			'action': 'create'
		}
	]
}

#
# systemd service definition
default['jenkins']['service'] = 'jenkins'
default['jenkins']['systemd'] = {
	'name': node['jenkins']['service'],
	'description': 'Jenkins service',
	'requires': node['docker']['service'],
	'after': node['docker']['service']
}

#
# docker images
default['jenkins']['docker']['image'] = {
	'jenkins-data' => {
		'name': 'jenkins-data',
		'source': '/srv/docker/jenkins-data',
		'action': 'build_if_missing'
	},
	'jenkins-master' => {
		'name': 'jenkins-master',
		'source': '/srv/docker/jenkins-master',
		'action': 'build_if_missing'
	},
}

# docker containers
default['jenkins']['docker']['container'] = {
	'jenkins-data' => {
		'name': 'jenkins-data',
		'repo': "#{node['jenkins']['docker']['image']['jenkins-data'].name}",
		'action': 'create'
	},
	'jenkins-master' => {
		'name': 'jenkins-master',
		'repo': "#{node['jenkins']['docker']['image']['jenkins-master'].name}",
		'volumes': ["/var/run/docker.sock:/var/run/docker.sock","/usr/bin/docker:/usr/bin/docker"],
		'port': ["8080:8080","50000:50000"],
		'volumes_from': 'jenkins-data',
		'action': 'create'
	},
}