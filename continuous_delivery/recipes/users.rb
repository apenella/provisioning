#
# Cookbook Name:: continuous_delivery
# Recipe:: users
#
# 2017 Aleix Penella
#

# create users
node['config']['users'].each do |u, info|
	user u do
  		#group info.group 
  		system info.system 
  		shell info.shell 
	end
end

# create groups
node['config']['groups'].each do |g, info|
	group g do
		members info.members
	end
end

