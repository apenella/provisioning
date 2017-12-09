#
# Cookbook Name:: continuous_delivery
# Attributes:: jenkins
#
# 2017 Aleix Penella
#

#
#
# System configuration
#

# service
default['jenkins']['service'] = 'jenkins'
# directories
default['jenkins']['directory'] = {
	'/srv/docker/jenkins-data' => {},
	'/srv/docker/jenkins-master' => {},
	'/srv/jenkins/.ssh' => {}
}
# config file for jenkins master
default['jenkins']['config']['file'] = {
	'name': '/tmp/config.xml',
	'source': 'jenkins/config.xml',
	'action': 'create',
	'execute': 'config.xml'
}
# setup for jenkins master
default['jenkins']['config']['setup'] = {
	'script': '/tmp/jenkins_master_setup.sh',
	'source': 'jenkins/jenkins_master_setup.sh',
	'mode': '0755',
	'action': 'create'
}

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
	'files' => {
		'do': true,
		'list': [
			"#{node['jenkins']['config']['setup'].script}",
			"#{node['jenkins']['config']['file'].name}"
		]
	},
	'images' => {
		'do': true,
		'list': [
			"#{node['jenkins']['docker']['image']['jenkins-data'].name}",
			"#{node['jenkins']['docker']['image']['jenkins-master'].name}"
		]
	}, 
	'containers' => {
		'do': true,
		'list': [
			"#{node['jenkins']['docker']['container']['jenkins-data'].name}",
			"#{node['jenkins']['docker']['container']['jenkins-master'].name}"
		]
	}
}