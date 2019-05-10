default['azure_pipelines_agent']['admin_user'] = 'vagrant'
default['azure_pipelines_agent']['user_group'] = 'staff'

default['azure_pipelines_agent']['pat'] = nil
default['azure_pipelines_agent']['data_bag'] = 'azure_pipelines'
default['azure_pipelines_agent']['data_bag_item'] = 'build_agent'

default['azure_pipelines_agent']['agent_name'] = node['hostname']
default['azure_pipelines_agent']['account'] = nil
default['azure_pipelines_agent']['agent_pool'] = nil

default['azure_pipelines_agent']['version'] = '2.150.3'
default['azure_pipelines_agent']['additional_environment'] = {}
default['azure_pipelines_agent']['service_name'] = 'com.microsoft.azure-pipelines-agent'

default['azure_pipelines_agent']['deployment_group'] = nil
default['azure_pipelines_agent']['deployment_group_tags'] = nil
default['azure_pipelines_agent']['project'] = nil
default['azure_pipelines_agent']['work'] = nil
