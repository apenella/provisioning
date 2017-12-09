#
# Cookbook Name:: continuous_delivery
# Recipe:: gitlab
#
# 2017 Aleix Penella
#

# create directories 
node['gitlab']['directory'].each do |d, info|
	directory d do
		recursive true
		action :create
	end
end

# pull docker image
docker_image node['gitlab']['docker']['image'].name do
	action :pull_if_missing
end

# create gitlab.rb config file
template '/srv/gitlab/config/gitlab.rb' do
	source 'gitlab.erb'
	mode '755'
	variables({
    		external_url:  node['gitlab']['config']['external_url'], 
    		listen_port:  node['gitlab']['config']['listen_port'], 
    		listen_https:  node['gitlab']['config']['listen_https'] 
  	})
  	#notifies :run, "docker_container[#{node['gitlab']['docker']['container'].name}]", :immediately
end

# run container
docker_container node['gitlab']['docker']['container'].name do
	repo node['gitlab']['docker']['container'].repo
	volumes node['gitlab']['docker']['container'].volumes
	port  node['gitlab']['docker']['container'].port
end

systemd_unit "#{node['gitlab']['service'].name}.service" do
	content <<-EOU.gsub(/^\s+/, '')
		[Unit]
		Description=gitlab service
		Requires=docker.service
		After=docker.service

		[Service]
		TimeoutStartSec=0
		ExecStart=/usr/bin/docker start -a gitlab
		ExecStop=/usr/bin/docker stop gitlab
		Restart=on-failure

		[Install]
		WantedBy=multi-user.target
	EOU

	action [:create, :enable] 	
end

#
# jenkins-master service
service "#{node['gitlab']['service'].name}.service" do
	action :restart
end