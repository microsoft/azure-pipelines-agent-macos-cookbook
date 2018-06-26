macosx_service 'stop agent service' do
  service_name Agent.service_name
  plist Agent.launchd_plist
  action [:disable, :stop]
end

file 'delete service name file' do
  path ::File.join Agent.agent_home, '.service'
  action :nothing
  subscribes :delete, 'file[delete service script]', :immediately
end

file 'delete service plist' do
  path Agent.launchd_plist
  action :nothing
  subscribes :delete, 'file[delete service name file]', :immediately
end

execute 'unconfigure VSTS agent' do
  cwd Agent.agent_home
  user Agent.admin_user
  command ['./bin/Agent.Listener', 'remove']
  environment lazy { Agent.vsts_environment }
  live_stream true
  action :nothing
  subscribes :run, 'file[delete service name file]', :immediately
end
