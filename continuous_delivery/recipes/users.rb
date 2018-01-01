#
# Cookbook Name:: continuous_delivery
# Recipe:: users
#
# 2017 Aleix Penella
#

# create users
node['config']['users'].each do |u, data|
	
	user u do
		if data.has_key?('password') then password "#{data.password}" end
		if data.has_key?('system') then system data.system end
		if data.has_key?('shell') then shell "#{data.shell}" end
		if data.has_key?('home') then
			puts ">> #{data.home}"
			puts ">> #{node['jenkins']}"
			Dir.mkdir("#{data.home}") unless Dir.exist?("#{data.home}")
			home "#{data.home}" 
		end
		if data.has_key?('gid') then gid "#{data.gid}" end
		if data.has_key?('uid') then uid "#{data.uid}" end	
	end

	if data.has_key?('groups') then
		data.groups.each do |g|
			group "#{u}_#{g}" do
				append true
				members u
				action :modify
			end
		end
	end

	if data.ssh && data.has_key?('home') then
		Dir.mkdir("#{data.home}/.ssh") unless Dir.exist?("#{data.home}/.ssh")
		ssh_keygen "#{data.home}/.ssh/id_rsa" do
			action :create
			owner u
			strength 4096
			type 'rsa'
			secure_directory true
		end
	end
end

#
# User Jenkins
#
# user 'jenkins' do
#   	group 'jenkins'
#   	home  '/srv/jenkins'
#   	system true
#   	notifies :create, "ssh_keygen[#{node['jenkins']['directory']['ssh']}/id_rsa]",:immediately
# end

# ssh_keygen "#{node['jenkins']['directory']['ssh']}/id_rsa" do
# 	action :create
# 	strength 4096
# 	type 'rsa'
# 	secure_directory true
# end

# create groups
# node['config']['groups'].each do |g, info|
# 	group g do
# 		members info.members
# 	end
# end