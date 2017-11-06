version = node['vsts_agent']['version']
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

tar_extract "https://github.com/Microsoft/vsts-agent/releases/download/v#{version}/vsts-agent-osx.10.11-x64-#{version}.tar.gz" do
  target_dir agent_home
  creates "#{agent_home}/setup_version"
  group 'admin'
  user admin
  download_dir "#{admin_home}/Downloads"
end

cookbook_file "#{agent_home}/bin/System.Net.Http.dll" do
  source 'System.Net.Http.dll'
  user admin
  group 'admin'
  only_if { on_high_sierra_or_newer? && !already_configured? }
end

execute 'configure agent' do
  command './config.sh --acceptteeeula --unattended'
  user admin
  environment vsts_environment
  cwd agent_home
  not_if { already_configured? }
end

execute 'install service' do
  command './svc.sh install'
  user admin
  environment vsts_environment
  cwd agent_home
  not_if { launchd_plist_exists? }
end

execute 'start service' do
  command './svc.sh start'
  user admin
  environment vsts_environment
  cwd agent_home
  not_if { service_started? }
end

directory "#{admin_home}/Downloads" do
  action :delete
  recursive true
end
