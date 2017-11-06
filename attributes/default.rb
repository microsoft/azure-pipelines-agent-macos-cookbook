default['vsts_agent']['agent_name'] = node['hostname']
default['vsts_agent']['version'] = 'latest'
default['vsts_agent']['account'] = 'office'
default['vsts_agent']['admin_user'] = 'vagrant'
default['vsts_agent']['agent_home'] = "/Users/#{node['vsts_agent']['admin_user']}/vsts-agent"
