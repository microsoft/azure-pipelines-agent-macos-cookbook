agent_attrs = node['azure_pipelines_agent']

if agent_attrs['pat']
  pat = agent_attrs['pat']
else
  auth_data = data_bag_item agent_attrs['data_bag'], agent_attrs['data_bag_item']
  pat = auth_data['personal_access_token']
end

auth_params = ['--auth', 'pat', '--token', pat]

macosx_service 'azure-pipelines-agent' do
  service_name Agent.service_name
  plist Agent.launchd_plist
  action [:disable, :stop]
end

file 'service name reference file' do
  path ::File.join Agent.agent_home, '.service'
  action :nothing
  subscribes :delete, 'file[service plist]'
end

file 'service plist' do
  path Agent.launchd_plist
  action :nothing
  subscribes :delete, 'file[service name reference file]'
end

execute 'remove agent' do
  cwd Agent.agent_home
  user Agent.admin_user
  command ['./bin/Agent.Listener', 'remove', *auth_params]
  environment lazy { Agent.environment }
  live_stream true
  action :nothing
  subscribes :run, 'file[service name reference file]'
end
