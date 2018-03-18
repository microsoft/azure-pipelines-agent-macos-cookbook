include_recipe 'homebrew::default'
homebrew_package 'git'
homebrew_package 'openssl'

directory '/usr/local/lib/' do
  recursive true
  owner admin_user
  group staff_group
end

link '/usr/local/lib/libcrypto.1.0.0.dylib' do
  to '/usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib'
  owner admin_user
  group staff_group
end

link '/usr/local/lib/libssl.1.0.0.dylib' do
  to '/usr/local/opt/openssl/lib/libssl.1.0.0.dylib'
  owner admin_user
  group staff_group
end

directory agent_home do
  owner admin_user
  group staff_group
end

directory "#{admin_library}/LaunchAgents" do
  recursive true
  owner admin_user
  group staff_group
end

directory "#{admin_home}/Downloads/vsts-agent" do
  recursive true
  owner admin_user
  group staff_group
end

remote_file target_path do
  source release_download_url
  owner admin_user
  group staff_group
  show_progress true
end

tar_extract target_path do
  target_dir agent_home
  group staff_group
  user admin_user
  action :extract_local
  only_if { agent_needs_update? }
end

directory "#{admin_home}/Downloads/vsts-agent" do
  user admin_user
  group staff_group
  action :nothing
  recursive true
  subscribes :delete, 'tar_extract[vsts agent source]', :delayed
end

execute 'bootstrap the agent' do
  cwd agent_home
  user admin_user
  command ['./bin/Agent.Listener', 'configure', '--acceptTeeEula', '--unattended']
  environment vsts_environment
  not_if { has_credentials? }
  live_stream true
end

service_log_path ::File.join admin_library, 'Logs', agent_service_name

directory 'create log directory' do
  path service_log_path
  recursive true
  owner admin_user
  group staff_group
end

ruby_block 'recursive permissions for logs' do
  block { ::FileUtils.chown_R admin_user, staff_group, service_log_path }
  action :nothing
  subscribes :run, 'directory[create log directory]', :immediately
end

file "#{agent_home}/runsvc.sh" do
  owner admin_user
  group staff_group
  content ::IO.read "#{agent_home}/bin/runsvc.sh"
  action :create
end

file 'create agent service file' do
  path "#{agent_home}/.service"
  owner admin_user
  group staff_group
  content launchd_plist
  action :create
end

template 'create environment file' do
  path "#{agent_home}/.env"
  source 'env.erb'
  owner admin_user
  group staff_group
  mode 0o755
  cookbook 'vsts_agent_macos'
end

launchd 'create launchd service plist' do
  path launchd_plist
  type 'agent'
  owner admin_user
  label agent_service_name
  program_arguments ["#{agent_home}/bin/runsvc.sh"]
  username admin_user
  working_directory agent_home
  run_at_load true
  standard_out_path ::File.join log_dir, 'stdout.log'
  standard_error_path ::File.join log_dir, 'stderr.log'
  environment_variables VSTS_AGENT_SVC: '1'
  session_type 'user'
  action [:create, :enable]
end

macosx_service 'restart-agent-service' do
  service_name agent_service_name
  user admin_user
  action :nothing
  subscribes :restart, 'template[environment file]'
end
