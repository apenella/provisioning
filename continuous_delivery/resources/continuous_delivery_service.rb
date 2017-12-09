#
# Cookbook Name:: continuous_delivery
# Custom resource:: service
#
# 2017 Aleix Penella
#

resource_name :continuous_delivery_service

property :name, String, name_property: true
property :image, Hash, default: {}
property :container, Hash, default: {}
property :systemd_service, Hash, default: {}

default_action :deploy

#
# deploy: create and image and runs a container. Even more, creates a systemd service to manage that container
action :deploy do

	#
	# pull docker image
	if !new_resource.image.empty? then
		docker_image new_resource.image['name'] do
			if new_resource.image.has_key?('repo')	then repo	new_resource.image['repo']	end
			if new_resource.image.has_key?('tag')	then tag	new_resource.image['tag']	end
			if new_resource.image.has_key?('source')	then source	new_resource.image['source']	end							
			if new_resource.image.has_key?('action')	then action	new_resource.image['action']	end
		end
	end

	#
	# run container
	if !new_resource.container.empty? then
		docker_container new_resource.container['name'] do
			repo 	new_resource.container['repo']
			if new_resource.container.has_key?('tag')	then	tag	new_resource.container['tag']	end
			if new_resource.container.has_key?('port')	then	port	new_resource.container['port']	end
			if new_resource.container.has_key?('volumes')	then	volumes	new_resource.container['volumes']	end
			if new_resource.container.has_key?('env')	then	env	new_resource.container['env']	end
			if new_resource.container.has_key?('action')	then	action	new_resource.container['action']	end
		end
	end

	#
	# define service
	if !new_resource.systemd_service.empty? then
		template "/lib/systemd/system/#{new_resource.systemd_service['name']}.service" do
			source 'systemd_service.erb'
			variables(
				description: new_resource.systemd_service['description'],
				requires: new_resource.systemd_service['requires'],
				after: new_resource.systemd_service['after'],
				container: new_resource.container['name']
			)
			mode '0644'
			action :create
		end

		#
		# enable and start service
		service new_resource.systemd_service['name'] do
			action [:enable, :start]
		end
	end
end

action :remove do
	puts ">>remove"
end

action :clear do
	#
	# clear systemd service
	if !new_resource.systemd_service.empty? then
		#
		# systemctl stop [servicename]
		# systemctl disable [servicename]
		# rm /etc/systemd/system/[servicename]
		# rm /etc/systemd/system/[servicename] symlinks that might be related
		# systemctl daemon-reload

		#
		# enable and start service
	  service new_resource.systemd_service['name'] do
	    action [:stop, :disable]
	  end

		file "/lib/systemd/system/#{new_resource.systemd_service['name']}.service" do
			only_if { ::File.exist?("/lib/systemd/system/#{new_resource.systemd_service['name']}.service") }
			action :delete
		end

		file "/etc/systemd/system/#{new_resource.systemd_service['name']}.service" do
			only_if { ::File.exist?("/etc/systemd/system/#{new_resource.systemd_service['name']}.service") }
			action :delete
			notifies :run, 'execute[daemon-reload]', :immediately
		end

		execute 'daemon-reload' do
			command "systemctl daemon-reload"
			action :nothing
		end
	end

	#
	# clear container
	if !new_resource.container.empty? then
		docker_container new_resource.container['name'] do
			if new_resource.container.has_key?('tag')	then	tag	new_resource.container['tag']	end
			remove_volumes true
			#only_if { "docker ps -a | grep #{new_resource.container['name']}"}
			action :delete
		end
	end
	
	#
	# clear image
	if !new_resource.image.empty? then
		docker_image new_resource.image['name'] do
			if new_resource.image.has_key?('repo')	then repo	new_resource.image['repo']	end
			if new_resource.image.has_key?('tag')	then tag	new_resource.image['tag']	end
			#only_if { "docker images | grep #{new_resource.container['name']}"}
			action :remove
		end
	end

end