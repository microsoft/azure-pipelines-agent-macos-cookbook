platform_version = ::Gem::Version.new node['platform_version']

if platform_version <= ::Gem::Version.new('10.11.6') && node['vsts_agent']['version'] == 'latest'
  node.normal['vsts_agent']['version'] = '2.124.0'
end

control_group 'audit' do
  control 'some test file' do
    let(:environment_file) { file('/Users/vagrant/vsts-agent/.env') }

    it 'should exist' do
      expect(environment_file).to exist
    end
  end
end

vsts_agent_macos 'agent_one' do
  action %i(stop_service uninstall_service remove)
end

# control 'agent and running' do
#   let(:vsts_agent_service) { service('vsts.agent.office') }
#
#   it 'should be enabled' do
#     expect(vsts_agent_service).to be_enabled
#   end
#
#   it 'should be running' do
#     expect(vsts_agent_service).to be_running
#   end
# end
