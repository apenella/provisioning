#
# Cookbook Name:: continuous_delivery
# Attributes:: users
#
# 2017 Aleix Penella
#

#
# users
default['config']['users'] = {
	'devops' => {
		'ssh' => true,
		'shell'	=> '/bin/bash',
		'system' => true,
		'groups' => [node['docker']['config']['group']]
	},
	'developer' => {
		'ssh' => true,
		'home' => "/developements",
		'shell'	=> '/bin/bash',
		'system' => true,
		'groups' => [node['docker']['config']['group']]
	},
	'jenkins' => {
		'ssh' => true,
		'home' => node['jenkins']['base_dir'],
		'shell'	=> '/bin/bash',
		'system' => true
	}
}