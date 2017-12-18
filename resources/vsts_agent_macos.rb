resource_name :vsts_agent_macos

property :agent_name, String, name_property: true

action_class do
  def admin_user
    node['vsts_agent']['admin_user']
  end

  def agent_home
    ::File.join('/Users', admin_user, 'vsts-agent')
  end

  def agent_name
    node['vsts_agent']['agent_name']
  end

  def admin_library
    "#{admin_home}/Library"
  end

  def admin_home
    "/Users/#{admin_user}"
  end

  def account_name
    node['vsts_agent']['account']
  end

  def vsts_environment
    default_environment.merge(additional_environment)
  end

  def additional_environment
    node['vsts_agent']['additional_environment']
  end

  def default_environment
    agent_data = data_bag_item('vsts', 'build_agent')
    { VSTS_AGENT_INPUT_URL: agent_data[:account_url],
      VSTS_AGENT_INPUT_AUTH: 'PAT',
      VSTS_AGENT_INPUT_TOKEN: agent_data[:personal_access_token],
      VSTS_AGENT_INPUT_POOL: node['vsts_agent']['agent_pool'],
      VSTS_AGENT_INPUT_AGENT: node['vsts_agent']['agent_name'],
      HOME: admin_home }
  end

  def launchd_plist
    "#{admin_library}/LaunchAgents/vsts.agent.#{account_name}.#{agent_name}.plist"
  end

  def agent_needs_update?
    if ::File.exist?("#{agent_home}/config.sh")
      config_path = ::File.join(agent_home, 'config.sh')
      current_version = shell_out(config_path, '--version', user: admin_user, env: vsts_environment).stdout.chomp
      requested_version = release_download_url.match(%r{\/v(\d+\.\d+\.\d+)\/}).to_a.last
      ::Gem::Version.new(requested_version) > ::Gem::Version.new(current_version)
    else
      true
    end
  end

  def needs_configuration?
    !::File.exist? "#{agent_home}/.credentials"
  end
end

action :install do
  homebrew_package 'git'
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

  directory "#{admin_home}/Downloads" do
    owner admin_user
    group 'staff'
  end

  tar_extract release_download_url do
    target_dir agent_home
    group 'admin'
    user admin_user
    download_dir "#{admin_home}/Downloads/vsts-agent"
    only_if { agent_needs_update? }
  end

  cookbook_file "#{agent_home}/bin/System.Net.Http.dll" do
    source 'System.Net.Http.dll'
    owner admin_user
    group 'admin'
    only_if { on_high_sierra_or_newer? && needs_configuration? }
  end

  directory "#{admin_home}/Downloads/vsts-agent" do
    action :nothing
    recursive true
    subscribes :delete, "tar_extract[#{release_download_url}]", :delayed
  end
end

action :configure do
  execute 'configure VSTS agent' do
    cwd agent_home
    user admin_user
    command ['./bin/Agent.Listener', 'configure', '--acceptTeeEula', '--unattended']
    environment vsts_environment
    only_if { needs_configuration? }
    live_stream true
  end
end

action :remove do
  execute 'unconfigure VSTS agent' do
    cwd agent_home
    user admin_user
    command ['./bin/Agent.Listener', 'remove']
    environment vsts_environment
    not_if { needs_configuration? }
    live_stream true
  end
end

action :install_service do
  directory "#{admin_library}/Logs" do
    recursive true
    owner admin_user
    group 'admin'
    mode 0o775
  end

  directory "#{admin_library}/Logs/vsts.agent.#{account_name}.#{agent_name}" do
    recursive true
    owner admin_user
    group 'admin'
    mode 0o775
  end

  file "#{agent_home}/runsvc.sh" do
    owner admin_user
    group 'admin'
    mode 0o775
    content ::File.open("#{agent_home}/bin/runsvc.sh").read
    action :create
  end

  file "#{agent_home}/.service" do
    owner admin_user
    group 'admin'
    mode 0o775
    content launchd_plist
    action :create
  end

  launchd "vsts.agent.#{account_name}.#{agent_name}" do
    path launchd_plist
    type 'agent'
    owner admin_user
    label "vsts.agent.#{account_name}.#{agent_name}"
    program_arguments ["#{agent_home}/bin/runsvc.sh"]
    username admin_user
    working_directory agent_home
    run_at_load true
    standard_out_path "#{admin_library}/Logs/vsts.agent.#{account_name}.#{agent_name}/stdout.log"
    standard_error_path "#{admin_library}/Logs/vsts.agent.#{account_name}.#{agent_name}/stderr.log"
    environment_variables VSTS_AGENT_SVC: '1'
    session_type 'user'
    action [:create, :enable]
  end
end

action :uninstall_service do
  file "#{agent_home}/runsvc.sh" do
    action :delete
  end

  file "#{agent_home}/.service" do
    action :delete
  end

  file launchd_plist do
    action :delete
  end
end

action :start_service do
  execute 'start service with launchctl' do
    user admin_user
    command [launchctl_command, 'load', '-w', launchd_plist]
    not_if { service_started? }
  end
end

action :stop_service do
  execute 'stop service with launchctl' do
    user admin_user
    command [launchctl_command, 'unload', launchd_plist]
    only_if { service_started? }
  end
end
