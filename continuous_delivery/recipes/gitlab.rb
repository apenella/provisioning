#
# Cookbook Name:: continuous_delivery
# Recipe:: gitlab
#
# 2017 Aleix Penella
#


#
# System configuration
#

#
# create directories 
node['gitlab']['directory'].each do |d, info|
	directory d do
		recursive true
		action :create
	end
end

#
# Gitlab
#

#
# clear service
if node['gitlab']['deploy']['clear'] then
	continuous_delivery_service "Clear #{node['gitlab']['systemd'].name}" do
		container node['gitlab']['docker']['container']
		systemd_service node['gitlab']['systemd']
		action :clear
	end
end

#
# deploy service
continuous_delivery_service node['gitlab']['systemd'].name do
	image node['gitlab']['docker']['image']
	container node['gitlab']['docker']['container']
	systemd_service node['gitlab']['systemd']
end

#
# create gitlab.rb config file
template '/srv/gitlab/config/gitlab.rb' do
	source 'gitlab.erb'
	mode '755'
	variables({
    		external_url:  node['gitlab']['config']['external_url'], 
    		listen_port:  node['gitlab']['config']['listen_port'], 
    		listen_https:  node['gitlab']['config']['listen_https'] 
  	})
end

#
# Gitlab service
service node['gitlab']['systemd'].name do
	action :restart
end