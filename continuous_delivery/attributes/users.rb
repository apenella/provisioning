#
# Cookbook Name:: continuous_delivery
# Attributes:: users
#
# 2017 Aleix Penella
#

#
# groups
default['groups']['config'] = {
	node['continuous_delivery']['group']['developers'] => {
		'group_name' => node['continuous_delivery']['group']['developers'],
		'system' => true,
		'action' => 'create'
	},
	node['continuous_delivery']['group']['docker'] => {
		'group_name' => node['continuous_delivery']['group']['developers'],
		'system' => true,
		'action' => 'create'
	}
}

#
# users
default['users']['config'] = {
	node['continuous_delivery']['user']['devops'] => {
		'ssh' => true,
		'home' => "/devops",
		'shell'	=> '/bin/bash',
		'system' => true,
		'groups' => [node['continuous_delivery']['group']['developers'], node['continuous_delivery']['group']['docker']]
	},
	node['continuous_delivery']['user']['developer'] => {
		'ssh' => true,
		'home' => "/developements",
		'shell'	=> '/bin/bash',
		'system' => true,
		'groups' => [node['continuous_delivery']['group']['developers'], node['continuous_delivery']['group']['docker']]
	},
	node['continuous_delivery']['user']['jenkins'] => {
		'ssh' => true,
		'home' => node['jenkins']['base_dir'],
		'shell'	=> '/bin/bash',
		'system' => true
	}
}