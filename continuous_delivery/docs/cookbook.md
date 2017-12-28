# Continuous delivery environment cookbook
This cookbook has been written to start an environment with the main components needed for a continuous integration or continuous delivery deployment.
The main components deployed using this cookbook are Jenkins, used for task automation and orchestration, GitLab, as a source code management system, and finally, docker registry, where are pushed the new releases' images.

A resource, named continuous_delivery_service, belonging at this cookbook, is responsible to create those elements needed for a service to be run.

> Note: This environment has been thought for testing, learning or developing purposes, then is not recomended to use it on a productive environment.

## Table of Contents

- [Precondition](#precondition)
- [Dependencies](#dependencies)
- [Resources](#resources)
  - [continuous_delivery_service](#continuous_delivery_service)
    - [Properties](#properties)
    - [Actions](#actions)
- [Recipes](#recipes)
  - [continuous_delivery-default](#continuous_delivery-default)
  - [continuous_delivery-registry](#registry)
  - [continuous_delivery-gitlab](#gitlab)
  - [continuous_delivery-jenkins](#jenkins)
  - [continuous_delivery-registry_ui](#registry_ui)
  - [continuous_delivery-portainer](#portainer)
- [Usage](#usage)
  - [Examples](#examples)
- [Author](#author)

## Preconditions
This cookbook has been developed and tested using:
- Vagrant version 1.8.7, with plugin vagrant-berkshelf 5.1.1
- Vagrant is forced to use chef version '12.20.3'
- Vagrant box ubuntu/xenial64, version 20170730.0.0

## Dependencies
Continuous delivery's cookbook depends to:
- [docker cookbook](https://supermarket.chef.io/cookbooks/docker), version '~> 2.0'
- [ssh_keygen cookbook](https://supermarket.chef.io/cookbooks/ssh_keygen), version '~> 1.1.0'

## Resources
In the next section, will be described the continuous_delivery_service resource, which is responsible to create those elements needed for a service to be run.

### continuous_delivery_service

#### Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>

  <tr>
    <td>name</td>
    <td>String</td>
    <td>Name for the service to be created</td>
  </tr>
  
  <tr>
    <td>image</td>
    <td>Hash</td>
    <td>
      It defines the image used by container's service.</br>
      The image's definition Hash properties are:</br> <tt>name</tt>(required), <tt>repo</tt>, <tt>tag</tt>, <tt>source</tt> or <tt>action</tt>, defined at <a href="https://github.com/chef-cookbooks/docker#docker_image">docker_image resource</a>.
      </br>
      Example:
      <pre><code>
{
  'name': 'registry',
  'tag': '2',
  'action': 'pull_if_missing'
}
      </pre></code>
    </td>
  </tr>

  <tr>
    <td>container</td>
    <td>Hash</td>
    <td>
      It defines the container where the service runs in.</br>
      The container's definition Hash properties are:</br> <tt>name</tt>(required), <tt>repo</tt>(required), <tt>tag</tt>, <tt>port</tt>, <tt>volumes</tt>, <tt>env</tt> or <tt>action</tt>, defined at <a href="https://github.com/chef-cookbooks/docker#docker_container">docker_container resource</a>.
      </br>
      Example:
      <pre><code>
{
  'name': 'registry',
  'repo': 'registry',
  'tag': '2',
  'port': '5000:5000',
  'env': [
    "REGISTRY_HOST=10.0.0.2 
  ],
  'action': 'create'
}
      </pre></code>
    </td>
  </tr>

  <tr>
    <td>files</td>
    <td>Array</td>
    <td>
      This property requires an array of hashes where are defined the files that must be copied from to host.</br>
      Each hash could have the properties <tt>file</tt>(required), <tt>source</tt>(required), <tt>mode</tt> or <tt>action</tt>, defined at <a href="https://docs.chef.io/resource_cookbook_file.html">cookbook_file resource</a>.
      </br>
      Example:
      <pre><code>
[
  {
    'file': '/srv/docker/jenkins-master/config.xml',
    'source': 'jenkins/config.xml',
    'action': 'create'
  },
  {
    'file': '/srv/docker/jenkins-master/jenkins_master_setup.sh',
    'source': 'jenkins/jenkins_master_setup.sh',
    'mode': '0755',
    'action': 'create'
  },
  {
    'file': '/srv/docker/jenkins-master/Dockerfile',
    'source': 'jenkins/jenkins-master/Dockerfile',
    'action': 'create'
  }
]
      </pre></code>
    </td>
  </tr>

  <tr>
    <td>systemd_service</td>
    <td>Hash</td>
    <td>
      Defines the systemd services based <tt>'systemd_service.erb'</tt> template.</br>
      The properties required to fill the template are:</br>
      <ul>
        <li>name: Container's name where the service runs in.</li>
        <li>description: A description about the service.</li>
        <li>requires: Dependencies to other services, like docker services.</li>
        <li>after: Whether services must start after another services. Mainly docker service.</li>
      </ul>
      </br>
      Example:
      <pre><code>
{
  'name': 'registry',
  'description': 'Service for private docker registry',
  'requires': 'docker',
  'after': 'docker'
}
      </pre></code>
    </td>
  </tr>

</table>

#### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>deploy</td>
    <td>Creates those elements needed for the service to be run.</td>
  </tr>
  <tr>
    <td>clear</td>
    <td>Removes all elements created during the service deployment.</td>
  </tr>
</table>

## Recipes
In the next section, are presented the recipies defined on this cookbook.

### continuous_delivery-default
Default recipe controls recipes execution, installing the required pieces to the host and then deploys the continuous delivery environment components.

There are some opcional components not deployed by default, like [Portainer](https://portainer.io/) or [Registry UI](https://github.com/parabuzzle/craneoperator), but is possible to deploy them changing some attributes' values. These attributes are described below.


<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['registry_ui']</tt></td>
    <td>Enables a web console to manage Registry service.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['portainer']</tt></td>
    <td>Enables Portainer's service, to manage docker engine.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
</table>

### continuous_delivery::registry
Registry recipe is responsible to deploy the docker registry where the new releases' images must be pushed to.

#### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['registry']['deploy']['clear']</tt></td>
    <td>Enable clear component's deployment before deploy it.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['registry']['service']</tt></td>
    <td>Name of the service.</td>
    <td>String</td>
    <td>-</td>
  </tr>
  <tr>
    <td><tt>['registry']['systemd']</tt></td>
    <td>Systemd service definition to be used on continuous_delivery_service resource.</td>
    <td>Hash</td>
    <td>
      <pre><cond>
{
  'name': node['registry']['service'],
  'description': 'Service for private docker registry',
  'requires': node['docker']['service'],
  'after': node['docker']['service']
}
      </pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['registry']['config']['host']</tt></td>
    <td>Host where is deployed Registry service.</td>
    <td>String</td>
    <td>0.0.0.0</td>
  </tr>
  <tr>
    <td><tt>['registry']['config']['port']</tt></td>
    <td>Port where listen to Registry.</td>
    <td>String</td>
    <td>5000</td>
  </tr>
  <tr>
    <td><tt>['registry']['config']['protocol']</tt></td>
    <td>Protocol where is configured Registry [http|https].</td>
    <td>String</td>
    <td>http</td>
  </tr>
  <tr>
    <td><tt>['registry']['config']['addr']</tt></td>
    <td>Registry address.</td>
    <td>String</td>
    <td>
      <pre><cond>
#{node['registry']['config']['host']}:#{node['registry']['config']['port']}
      </pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['registry']['docker']['image']</tt></td>
    <td>Image definition to be used on continuous_delivery_service resource.</td>
    <td>Hash</td>
    <td>
      <pre><cond>
{
  'name': 'registry',
  'tag': '2',
  'action': 'pull_if_missing'
}
      </pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['registry']['docker']['container']</tt></td>
    <td>Container definition to be used on continuous_delivery_service resource.</td>
    <td>Hash</td>
    <td>
      <pre><cond>
{
  'name': "#{node['registry']['service']}",
  'repo': "#{node['registry']['docker']['image'].name}",
  'tag': "#{node['registry']['docker']['image'].tag}",
  'port': "5000:#{node['registry']['config']['port']}",
  'env': [
    "REGISTRY_HOST=#{node['registry']['config']['host']}",
    "REGISTRY_STORAGE_DELETE_ENABLED=true"
  ],
  'action': 'create'
}
      </pre></cond>
    </td>
  </tr>

</table>

### continuous_delivery::gitlab
Gitlab recipe is responsible to deploy the Gitlab component used as source code management system.

#### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitlab']['deploy']['clear']</tt></td>
    <td>Enable clear component's deployment before deploy it.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['gitlab']['config']['external_url']</tt></td>
    <td>External URL to login to GitLab.</td>
    <td>String</td>
    <td>http://localhost</td>
  </tr>
  <tr>
    <td><tt>['gitlab']['config']['listen_port']</tt></td>
    <td>Port configured to access into GitLab web portal.</td>
    <td>Integer</td>
    <td>80</td>
  </tr>
  <tr>
    <td><tt>['gitlab']['config']['ssh_port']</tt></td>
    <td>Port configured to access into GitLab using ssh.</td>
    <td>Integer</td>
    <td>2222</td>
  </tr>
  <tr>
    <td><tt>['gitlab']['config']['listen_https']</tt></td>
    <td>Enable https access.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['gitlab']['directory']</tt></td>
    <td>List of directories to be created on host.</td>
    <td>Hash</td>
    <td>
<pre><cond>
{
  '/srv/gitlab/data' => {},
  '/srv/gitlab/logs' => {},
  '/srv/gitlab/config' => {}
}
</pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['gitlab']['files']</tt></td>
    <td>List of files to be used on continuous_delivery_service resource.</td>
    <td>Array</td>
    <td>
<pre><cond>
[
  {
    'file': '/srv/gitlab/config/gitlab.rb',
    'source': '#is a template and will not be created be continuous_delivery_services resource',
    'action': 'create'
  }
]
</pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['gitlab']['service']</tt></td>
    <td>Name of the service.</td>
    <td>String</td>
    <td>-</td>
  </tr>
  <tr>
    <td><tt>['gitlab']['systemd']</tt></td>
    <td>Systemd service definition to be used on continuous_delivery_service resource.</td>
    <td>Hash</td>
    <td>
      <pre><cond>
{
  'name': node['gitlab']['service'],
  'description': 'gitlab service',
  'requires': node['docker']['service'],
  'after': node['docker']['service']
}
      </pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['gitlab']['docker']['image']</tt></td>
    <td>Image definition to be used on continuous_delivery_service resource.</td>
    <td>Hash</td>
    <td>
      <pre><cond>
{
  'name': 'gitlab/gitlab-ce',
  'tag': 'latest',
  'action': 'pull_if_missing'
}
      </pre></cond>
    </td>
  </tr>
  <tr>
    <td><tt>['gitlab']['docker']['container']</tt></td>
    <td>Container definition to be used on continuous_delivery_service resource.</td>
    <td>Hash</td>
    <td>
      <pre><cond>
{
  'name': 'gitlab',
  'repo': "#{node['gitlab']['docker']['image'].name}",
  'volumes': [
    "/srv/gitlab/data:/var/opt/gitlab",
    "/srv/gitlab/logs:/var/log/gitlab",
    "/srv/gitlab/config:/etc/gitlab"
  ],
  'port': [
    "80:80",
    "443:443",
    "#{node['gitlab']['config']['ssh_port']}:22"
  ],
  'action': 'create'
}
      </pre></cond>
    </td>
  </tr>


</table>

### continuous_delivery::jenkins
Jenkins recipe is responsible to deploy the Jenkins component, which lets to automate the delivery process and to release our application frequently.

#### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['jenkins']['deploy']['clear']</tt></td>
    <td>Enable clear component's deployment before deploy it.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['registry_ui']</tt></td>
    <td>Enable a web console for to manage Registry service.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['portainer']</tt></td>
    <td>Enable Portainer's service, to manage docker engine.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
</table>

### continuous_delivery::registry_ui
Registry UI recipe is responsible to deploy the component which will let to control the environment's docker registry status.

#### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['registry_ui']['deploy']['clear']</tt></td>
    <td>Enable clear component's deployment before deploy it.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['registry_ui']</tt></td>
    <td>Enable a web console for to manage Registry service.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['portainer']</tt></td>
    <td>Enable Portainer's service, to manage docker engine.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
</table>

### continuous_delivery::portainer
Portainer recipe is responsible to deploy the component which will let to control the host's docker engine.

#### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['portainer']['deploy']['clear']</tt></td>
    <td>Enable clear component's deployment before deploy it.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['registry_ui']</tt></td>
    <td>Enable a web console for to manage Registry service.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['service']['portainer']</tt></td>
    <td>Enable Portainer's service, to manage docker engine.</td>
    <td>Boolean</td>
    <td>false</td>
  </tr>
</table>


## Usage
Include `continuous_delivery` in your node's `run_list`:

```ruby
env.vm.provision "chef_solo" do |chef|
  chef.add_recipe "continuous_delivery"
end
```
### Examples
Some examples of how to modify your deployment changing the attributes' default values, into `Vagrantfile`.

- Enable Portainer service:

```ruby
env.vm.provision "chef_solo" do |chef|
  chef.add_recipe "continuous_delivery"
  chef.json = {
    :continuous_delivery => {
      :service => {
        :portainer => true,
        :registry_ui => false
      }
    }
  }
end
```

- Clear old Registry before its new deployment:

```ruby
env.vm.provision "chef_solo" do |chef|
  chef.add_recipe "continuous_delivery"
  chef.json = {
  :registry => {
    :deploy => {
      :clear => true
    }
  }  
}
end
```

## Author

Author:: Aleix Penella (aleix.penella@gmail.com)