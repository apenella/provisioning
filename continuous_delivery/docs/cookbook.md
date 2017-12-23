# Continuous delivery environment cookbook
This cookbook has been written to start an environment with the main components needed for a continuous integration or continuous delivery deployment.
The main components deployed using this cookbook are Jenkins, used for task automation and orchestration, GitLab, as a source code management system, and finally, docker registry, where are pushed the new releases' images.

A resource, named continuous_delivery_service, belonging at this cookbook, is responsible to create those elements needed for a service to be run.

> Note: This environment has been thought for testing, learning or developing purposes, then is not recomended to use it on a productive environment.

## Dependencies
Continuous delivery's cookbook has dependencies to:
- [docker cookbook](https://supermarket.chef.io/cookbooks/docker), version '~> 2.0'
- [ssh_keygen cookbook](https://supermarket.chef.io/cookbooks/ssh_keygen), version '~> 1.1.0'

## resources
In the next section, will be described the _continuous_delivery_service, which is responsible to create those elements needed for a service to be run.

### continuous_delivery_service

*Properties
<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>name</tt></td>
    <td>String</td>
    <td>Name for the service to be created</td>
    <td><tt>-</tt></td>
  </tr>
  <tr>
    <td><tt>image</tt></td>
    <td>Hash</td>
    <td>It defines the image used by container's service.
The Hash could have the properties <tt>name</tt>(required), <tt>repo</tt>, <tt>tag</tt>, <tt>source</tt> or <tt>action</tt>, defined on [docker_image resource](https://github.com/chef-cookbooks/docker#docker_image).

Example:
```
{
  'name': 'registry',
  'tag': '2',
  'action': 'pull_if_missing'
}
```
    </td>
    <td><tt>{}</tt></td>
  </tr>
  <tr>
    <td><tt>container</tt></td>
    <td>Hash</td>
    <td>It defines the container where the service runs in.
The Hash could have the properties <tt>name</tt>(required), <tt>repo</tt>(required), <tt>tag</tt>, <tt>port</tt>, <tt>volumes</tt>, <tt>env</tt> or <tt>action</tt>, defined on [docker_container resource](https://github.com/chef-cookbooks/docker#docker_container).

Example:
```
{
  'name': 'registry',
  'repo': 'registry',
  'tag': '2',
  'port': '5000:5000'
  'env': [
    "REGISTRY_HOST=10.0.0.2 
  ],
  'action': 'create'
}
```
    </td>
    <td><tt>{}</tt></td>
  </tr>
  <tr>
    <td><tt>files</tt></td>
    <td>Array</td>
    <td>This property requires an array of hashes where are defined the files that must be copied from to host.
Each hash could have the properties <tt>file</tt>(required), <tt>source</tt>(required), <tt>mode</tt> or <tt>action</tt>, defined on [cookbook_file resource](https://docs.chef.io/resource_cookbook_file.html).

Example:
```
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
```
    </td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>systemd_service</tt></td>
    <td>Hash</td>
    <td>Defines the systemd services based <tt>'systemd_service.erb'</tt> template.
The properties required to fill the template are: 
- <tt>name</tt>: Container's name where the service runs in.
- <tt>description</tt>: A description about the service.
- <tt>requires</tt>: Dependencies to other services, like docker services.
- <tt>after</tt>: Whether services must start after another services. Mainly docker service.

Example:
```
{
  'name': 'registry',
  'description': 'Service for private docker registry',
  'requires': 'docker',
  'after': 'docker'
}
```
      </td>
    <td><tt>{}</tt></td>
  </tr>
</table>

*Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>deploy</tt></td>
    <td>Creates those elements needed for the service to be run.</td>
  </tr>
  <tr>
    <td><tt>clear</tt></td>
    <td>Removes all elements created during the service deployment.</td>
  </tr>
</table>

## recipes
In the next section, are presented the recipies

### continuous_delivery::default
Default recipe controls the others recipes execution, installing the required pieces to the host and then deploys the continuous delivery environment components.

There are some opcional components not deployed by default, like [Portainer](https://portainer.io/) or [Registry UI](https://github.com/parabuzzle/craneoperator), but is possible to deploy them changing some attributes' values. These attributes are described below.

*Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
    <th>Default</th>
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

### continuous_delivery::registry

### continuous_delivery::gitlab

### continuous_delivery::jenkins

### continuous_delivery::registry_ui

### continuous_delivery::portainer


*Attributes*

## Usage

### continuous_delivery::default

Include `continuous_delivery` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[continuous_delivery::default]"
  ]
}
```

## License and Authors

Author:: Aleix Penella (aleix.penella@gmail.com)