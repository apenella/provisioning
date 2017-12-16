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
default['jenkins']['directory'] = {
	'/srv/docker/jenkins-data' => {},
	'/srv/docker/jenkins-master' => {},
	'/srv/jenkins/.ssh' => {}
}

#
# files that must been copied to server
default['jenkins']['files'] = {
	'jenkins-data' => [
		{
			'file': '/srv/docker/jenkins-master/Dockerfile',
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
# config file for jenkins master
default['jenkins']['config']['file'] = {
	'name': '/tmp/config.xml',
	'source': 'jenkins/config.xml',
	'action': 'create',
	'execute': 'config.xml'
}

#
# setup for jenkins master
default['jenkins']['config']['setup'] = {
	'script': '/tmp/jenkins_master_setup.sh',
	'source': 'jenkins/jenkins_master_setup.sh',
	'mode': '0755',
	'action': 'create'
}

#
# docker images
default['jenkins']['docker']['image'] = {
	'jenkins-data' => {
		'name': 'jenkins-data',
		'source': '/srv/docker/jenkins-data',
		'build': '/srv/docker/jenkins-data/Dockerfile',
		'orig': 'jenkins/jenkins-data/Dockerfile',
		'action': 'build_if_missing'
	},
	'jenkins-master' => {
		'name': 'jenkins-master',
		'source': '/srv/docker/jenkins-master',
		'build': '/srv/docker/jenkins-master/Dockerfile',
		'orig': 'jenkins/jenkins-master/Dockerfile',
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

# attributes defined to clean the jenkins environment
default['jenkins']['clear'] = {
	'jenkins-data' => {
		'files': [
			"#{node['jenkins']['docker']['image']['jenkins-data'].build}"
		]
	},
	'jenkins-master' => {
		'files': [
			"#{node['jenkins']['docker']['image']['jenkins-master'].build}",
			"#{node['jenkins']['config']['setup'].script}",
			"#{node['jenkins']['config']['file'].name}"
		]
	}
}