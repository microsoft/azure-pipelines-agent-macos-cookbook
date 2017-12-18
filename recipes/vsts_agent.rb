platform_version = ::Gem::Version.new(node['platform_version'])

if platform_version <= ::Gem::Version.new('10.11.6') && node['vsts_agent']['version'] == 'latest'
  node.normal['vsts_agent']['version'] = '2.124.0'
end

vsts_agent_macos 'agent_one' do
  action %i(install configure install_service start_service)
end
