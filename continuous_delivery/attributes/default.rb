#
# Cookbook Name:: continuous_delivery
# Attributes:: default
#
# 2017 Aleix Penella
#

#
#
# globla attributes
#

#
# services
default['continuous_delivery']['service']['docker'] = 'docker'
default['continuous_delivery']['service']['jenkins'] = 'jenkins'
default['continuous_delivery']['service']['registry'] = 'registry'
default['continuous_delivery']['service']['gitlab'] = 'gitlab'
default['continuous_delivery']['service']['portainer'] = 'portainer'
default['continuous_delivery']['service']['registry_ui'] = 'registry-ui'

#
# groups
default['continuous_delivery']['group']['docker'] = 'docker'
default['continuous_delivery']['group']['developers'] = 'dev'

#
# users
default['continuous_delivery']['user']['devops'] = 'devops'
default['continuous_delivery']['user']['developer'] = 'developer'
default['continuous_delivery']['user']['jenkins'] = 'jenkins'

#
#
# enable utilities deployment
#

#
# portainer: manages docker engine
default['continuous_delivery']['deploy']['portainer'] = false

#
# registry-ui: web console for registry
default['continuous_delivery']['deploy']['registry_ui'] = false

#
# NOT READY
# slack: notification service
#default['continuous_delivery']['deploy']['slack'] = false

#
# NOT READY
# elk: store jenkins logs and generate reports
#default['continuous_delivery']['deploy']['elk'] = false