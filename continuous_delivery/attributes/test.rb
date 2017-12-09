#
# Cookbook Name:: continuous_delivery
# Attributes:: demo
#
# 2017 Aleix Penella
#

#
# system
default['test']['directory'] = {
	'/srv/test' => {}
}

# docker images
default['test']['docker']['image'] = {
	'nimmis/alpine-golang' => {
		'repo': 'nimmis/alpine-golang',
		'tag': 'latest',
		'action': 'pull_if_missing'
	}
}