#
# Cookbook Name:: continuous_delivery
# Recipe:: docker
#
# 2017 Aleix Penella
#
require 'json'

docker_service 'default' do
	group node['continuous_delivery']['group']['docker']
	action [:create, :start]
end

directory node['docker']['config']['directory'] do
	recursive true
	action :create
end


# configure insecure registry to test de continuous delivery platform
insecure_registries = Array.new
# achieve registry from cookbook attributes (these attribute could be set from Vagrantfile)
node['docker']['config']['registry'].each do |r|
	if r.insecure
		insecure_registries.push(r.registry)
	end
end

# manage docker configuration
if insecure_registries.length > 0
	if File.exist?("#{node['docker']['config']['daemon']}")
		daemon_json = JSON.parse(File.read("#{node['docker']['config']['daemon']}"))
		
		if daemon_json.has_key?('insecure-registries')
			insecure_registries.each do |i|
				if !daemon_json['insecure-registries'].include?(i)
					daemon_json['insecure-registries'].push(i)
				end
			end
		else
			daemon_json['insecure-registries'] = insecure_registries
		end
		puts daemon_json
	else
		Dir.mkdir("#{node['docker']['config']['directory']}") unless Dir.exist?("#{node['docker']['config']['directory']}")
		daemon_json = {'insecure-registries'=>insecure_registries}
	end

	daemon_file = File.open("#{node['docker']['config']['daemon']}", "w")
	daemon_file.puts(JSON.pretty_generate(daemon_json))
	daemon_file.close

	#
	# docker service restart
	service "#{node['continuous_delivery']['service']['docker']}" do
		action :restart
	end
end