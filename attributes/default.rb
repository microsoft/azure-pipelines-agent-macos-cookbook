default['vsts_agent']['admin_user'] = 'vagrant'
default['vsts_agent']['user_group'] = 'staff'
default['vsts_agent']['data_bag'] = 'vsts'
default['vsts_agent']['data_bag_item'] = 'build_agent'

default['vsts_agent']['agent_name'] = node['hostname']
default['vsts_agent']['account'] = 'americanhanko'
default['vsts_agent']['agent_pool'] = "American Hanko's Agents"
default['vsts_agent']['version'] = '2.131.0'
default['vsts_agent']['additional_environment'] = {}
default['vsts_agent']['service_name'] = 'com.microsoft.vsts-agent'
