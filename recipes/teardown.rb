vsts_attrs = node['vsts_agent']

if vsts_attrs['pat']
  pat = vsts_attrs['pat']
else
  auth_data = chef_vault_item vsts_attrs['data_bag'], vsts_attrs['data_bag_item']
  pat = auth_data['personal_access_token']
end

auth_params = ['--auth', 'pat', '--token', pat]

macosx_service 'vsts-agent' do
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
  environment lazy { Agent.vsts_environment }
  live_stream true
  action :nothing
  subscribes :run, 'file[service name reference file]'
end
