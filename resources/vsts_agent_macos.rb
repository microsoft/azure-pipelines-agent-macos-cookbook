resource_name :vsts_agent_macos

property :agent_name, String, name_property: true

action_class do
  include VstsAgent::VstsHelpers

  def admin_user
    node['vsts_agent']['admin_user']
  end

  def staff_group
    'staff'
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

  def account_url
    'https://' + account_name + '.visualstudio.com'
  end

  def vsts_environment
    default_environment.merge(additional_environment)
  end

  def additional_environment
    node['vsts_agent']['additional_environment']
  end

  def default_environment
    { VSTS_AGENT_INPUT_URL: account_url,
      VSTS_AGENT_INPUT_AUTH: 'PAT',
      VSTS_AGENT_INPUT_TOKEN: agent_data[:personal_access_token],
      VSTS_AGENT_INPUT_POOL: node['vsts_agent']['agent_pool'],
      VSTS_AGENT_INPUT_AGENT: node['vsts_agent']['agent_name'],
      HOME: admin_home }
  end

  def target_path
    ::File.join(agent_home, ::File.basename(release_download_url))
  end

  def agent_data
    data_bag_item node['vsts_agent']['data_bag'], node['vsts_agent']['data_bag_item']
  end

  def launchd_plist
    "#{admin_library}/LaunchAgents/vsts.agent.#{account_name}.#{agent_name}.plist"
  end

  def agent_needs_update?
    if ::File.exist?("#{agent_home}/config.sh")
      config_path = ::File.join(agent_home, 'config.sh')
      current_version = shell_out(config_path, '--version', user: admin_user, env: vsts_environment).stdout.chomp
      version_pattern = Regexp.new "\d+\.\d+\.\d+"
      requested_version = release_download_url.match(version_pattern).to_a.last
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
    group staff_group
  end

  directory "#{admin_library}/Logs/vsts.agent.#{account_name}.#{agent_name}" do
    recursive true
    owner admin_user
    group staff_group
  end

  file "#{agent_home}/runsvc.sh" do
    owner admin_user
    group staff_group
    content ::File.open("#{agent_home}/bin/runsvc.sh").read
    action :create
  end

  file "#{agent_home}/.service" do
    owner admin_user
    group staff_group
    content launchd_plist
    action :create
  end

  template "#{agent_home}/.service" do
    source 'env.erb'
    owner admin_user
    group staff_group
    mode 0o755
    variables()
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

action :start_service do
  execute 'start service with launchctl' do
    user admin_user
    command [launchctl_command, 'load', '-w', launchd_plist]
    not_if { service_started? }
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

action :stop_service do
  execute 'stop service with launchctl' do
    user admin_user
    command [launchctl_command, 'unload', launchd_plist]
    only_if { service_started? }
  end
end
