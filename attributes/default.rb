default['vsts_agent']['version'] = 'latest'
default['vsts_agent']['agent_name'] = node['hostname']
default['vsts_agent']['account'] = 'office'
default['vsts_agent']['agent_pool'] = 'Hosted macOS Preview'
default['vsts_agent']['additional_environment'] = {}

default['vsts_agent']['admin_user'] = 'vagrant'
