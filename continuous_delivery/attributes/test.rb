#
# Cookbook Name:: continuous_delivery
# Attributes:: test
#
# 2017 Aleix Penella
#

#
# directories
default['test']['base_dir'] = '/developements'
default['test']['simple-go-helloworld_dir'] = "#{default['test']['base_dir']}/simple-go-helloworld"
default['test']['directory'] = {
	default['test']['base_dir'] => {},
	default['test']['simple-go-helloworld_dir'] => {}
}


default['test']['code'] = [
	{
		'source': 'test/simple-go-helloworld',
		'dest': default['test']['simple-go-helloworld_dir'],
		'owner': node['continuous_delivery']['user']['developer'],
		'group': node['continuous_delivery']['group']['developers'],
		'mode': '0774',
		'recursive': true,
		'action': 'create',
		'clean': true
	}
]

# docker images
default['test']['docker']['image'] = {
	'nimmis/alpine-golang' => {
		'repo': 'nimmis/alpine-golang',
		'tag': 'latest',
		'action': 'pull_if_missing'
	}
}