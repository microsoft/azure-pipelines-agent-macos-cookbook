macosx_service 'stop-agent-service' do
  service_name agent_service_name
  user admin_user
  action [:disable, :stop]
end

file 'delete-service-script' do
  path "#{agent_home}/runsvc.sh"
  action :nothing
  subscribes :delete, 'macosx_service[stop-agent-service]', :immediately
end

file 'delete-service-name-file' do
  path "#{agent_home}/.service"
  action :nothing
  subscribes :delete, 'file[delete-service-script]', :immediately
end

file 'delete-service-plist' do
  path launchd_plist
  action :nothing
  subscribes :delete, 'file[delete-service-name-file]', :immediately
end

execute 'unconfigure VSTS agent' do
  cwd agent_home
  user admin_user
  command ['./bin/Agent.Listener', 'remove']
  environment vsts_environment
  not_if { has_credentials? }
  live_stream true
  action :nothing
  subscribes :delete, 'file[delete-service-name-file]', :immediately
end
