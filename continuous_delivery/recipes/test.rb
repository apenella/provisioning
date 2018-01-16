#
# Cookbook Name:: continuous_delivery
# Recipe:: test
#
# 2017 Aleix Penella
#

# create directory and copy content to it
node['test']['code'].each do |dir|
	if dir.clean then
		remote_directory "delete #{dir.dest}" do
			path dir.dest
			action :delete
			only_if {::Dir.exist?("#{dir.dest}")}
		end
	end

	remote_directory dir.dest do
		source dir.source
		if dir.has_key?('path') then path dir.path end
		if dir.has_key?('owner') then owner dir.owner end
		if dir.has_key?('group') then group dir.group end
		if dir.has_key?('recursive') then recursive dir.recursive end
		if dir.has_key?('mode') then mode dir.mode end
		if dir.has_key?('action') then action dir.action end
	end

	if dir.has_key?('owner') and dir.has_key?('group') then
		execute "chown #{dir.dest}" do
			command "chown -R #{dir.owner}:#{dir.group} #{dir.dest}"
			user "root"
			only_if {::Dir.exist?("#{dir.dest}")}
			action :run
		end
	end
end