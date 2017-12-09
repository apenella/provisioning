#
# Cookbook Name:: continuous_delivery
# Recipe:: demo
#
# 2017 Aleix Penella
#

#
# create directories 
node['test']['directory'].each do |d, info|
	directory d do
		recursive true
		action :create
		notifies :create, "remote_directory[#{d}]", :immediately
	end
end

#
# copy content to demo directory
remote_directory '/srv/test' do
	source 'test'
	action :nothing
end


# http_request 'list_users' do
# 	url "#{node['gitlab']['api']['url']}#{node['gitlab']['api']['request']['list_users'].url}"
# 	action node['gitlab']['api']['request']['list_users'].action
# 	headers ({
# 		'PRIVATE-TOKEN' => "#{node['gitlab']['auth']['access_token']}"
# 	})
# end