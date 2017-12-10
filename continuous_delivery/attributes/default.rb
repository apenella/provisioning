#
# Cookbook Name:: continuous_delivery
# Attributes:: default
#
# 2017 Aleix Penella
#

#
#
# enable utilities deployment
#

# portainer: manages docker engine
default['continuous_delivery']['service']['portainer'] = false
# registry-ui: web console for registry
default['continuous_delivery']['service']['registry_ui'] = false
# slack: notification service
default['continuous_delivery']['service']['slack'] = false
# elk: store jenkins logs and generate reports
default['continuous_delivery']['service']['elk'] = false

#
# groups
default['config']['groups'] = {
	'docker' => { 
		'members' => ['ubuntu','devops'],
		'gid': 1001 
	}
}

#
# users
default['config']['users'] = {
	'devops' => {
		'shell'	=> '/bin/bash',
		'system' => true,
	}
}