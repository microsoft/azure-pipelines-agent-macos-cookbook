admin = node['vsts_agent']['admin_user']

homebrew_package 'openssl'

directory '/usr/local/lib/' do
  recursive true
  owner admin
  group 'admin'
end

link '/usr/local/lib/libcrypto.1.0.0.dylib' do
  to '/usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib'
  owner admin
end

link '/usr/local/lib/libssl.1.0.0.dylib' do
  to '/usr/local/opt/openssl/lib/libssl.1.0.0.dylib'
  owner admin
end

directory agent_home do
  owner admin
  group 'staff'
end

directory "#{admin_home}/Library/LaunchAgents" do
  recursive true
  owner admin
  group 'staff'
end

tar_extract release_download_url do
  target_dir agent_home
  creates "#{agent_home}/setup_version"
  group 'admin'
  user admin
  download_dir "#{admin_home}/Downloads"
  only_if { agent_needs_update? }
end

cookbook_file "#{agent_home}/bin/System.Net.Http.dll" do
  source 'System.Net.Http.dll'
  user admin
  group 'admin'
  only_if { on_high_sierra_or_newer? && !already_configured? }
end

execute 'configure agent' do
  command './config.sh --acceptteeeula --unattended --replace'
  user admin
  environment vsts_environment
  cwd agent_home
  not_if { already_configured? }
end

directory "#{admin_home}/Library/Logs" do
  recursive true
  owner admin
end

directory "#{admin_home}/Library/Logs/vsts.agent.office.#{node['vsts_agent']['agent_name']}" do
  recursive true
  owner admin
end

launchd "vsts.agent.office.#{node['vsts_agent']['agent_name']}" do
  label "vsts.agent.office.#{node['vsts_agent']['agent_name']}"
  program_arguments ["#{agent_home}/runsvc.sh"]
  username admin
  working_directory agent_home
  run_at_load true
  standard_out_path "#{admin_home}/Library/Logs/vsts.agent.office.#{node['vsts_agent']['agent_name']}/stdout.log"
  standard_error_path "#{admin_home}/Library/Logs/vsts.agent.office.#{node['vsts_agent']['agent_name']}/stdout.log"
  environment_variables VSTS_AGENT_SVC: '1'
  action [:create, :enable]
end

directory "#{admin_home}/Downloads" do
  action :delete
  recursive true
end
