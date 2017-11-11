resource_name :vsts_agent_macos
default_action :install


action :install do

homebrew_package 'openssl'

  directory '/usr/local/lib/' do
    recursive true
    owner admin_user
    group 'admin'
  end

  link '/usr/local/lib/libcrypto.1.0.0.dylib' do
    to '/usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib'
    owner admin_user
  end

  link '/usr/local/lib/libssl.1.0.0.dylib' do
    to '/usr/local/opt/openssl/lib/libssl.1.0.0.dylib'
    owner admin_user
  end

  directory agent_home do
    owner admin_user
    group 'staff'
  end

  directory "#{admin_library}/LaunchAgents" do
    recursive true
    owner admin_user
    group 'staff'
  end

  tar_extract release_download_url do
    target_dir agent_home
    creates "#{agent_home}/setup_version"
    group 'admin'
    user admin_user
    download_dir "#{admin_home}/Downloads"
    only_if { needs_configuration? || agent_needs_update? }
  end

  cookbook_file "#{agent_home}/bin/System.Net.Http.dll" do
    source 'System.Net.Http.dll'
    owner admin_user
    group 'admin'
    only_if { on_high_sierra_or_newer? && needs_configuration? }
  end
end

action :configure do

  file 'runsvc.sh' do
    cwd agent_home
    owner admin_user
    group 'admin'
    mode 0o755
    content ::File.open('./bin/runsvc.sh').read
    action :create
  end

# execute 'configure agent' do
#   command './config.sh --acceptteeeula --unattended --replace'
#   user admin_user
#   environment vsts_environment
#   cwd agent_home
#   only_if { needs_configuration? }
# end

  directory "#{admin_library}/Logs" do
    recursive true
    owner admin_user
  end

  directory "#{admin_library}/Logs/vsts.agent.office.#{agent_name}" do
    recursive true
    owner admin_user
  end

  file launchd_plist do
    action :delete
    only_if { !service_started? || service_needs_reinstall? }
  end

# execute 'install service' do
#   user admin_user
#   command './svc.sh install'
#   cwd agent_home
#   environment vsts_environment
#   not_if { service_started? && !service_needs_reinstall? }
# end

# execute 'start service' do
#   user admin_user
#   command './svc.sh start'
#   cwd agent_home
#   environment vsts_environment
#   not_if { service_started? }
# end



# execute 'remove agent' do
#   command './svc.sh uninstall && ./config.sh remove'
#   user admin_user
#   environment vsts_environment
#   cwd agent_home
#   only_if { !needs_configuration? && !service_started? && !service_needs_reinstall? }
#   notifies :run, 'execute[reconfigure agent]', :immediately
# end

# execute 'reconfigure agent' do
#   command './config.sh --acceptteeeula --unattended --replace'
#   user admin_user
#   environment vsts_environment
#   cwd agent_home
#   action :nothing
#   notifies :run, 'execute[start service]', :immediately
# end

directory "#{admin_home}/Downloads" do
  action :delete
  recursive true
end
