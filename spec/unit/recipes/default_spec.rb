require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../../../libraries/agent'

include VstsAgentMacOS

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end

shared_context 'with the VSTS Agent.Worker process running' do
  before do
    allow(Agent).to receive(:worker_running?).and_return true
    stub_data_bag_item('vsts', 'build_agent').and_return personal_access_token: 'p9817234jhbasdfo87q234bnsadfasdf234'
  end
  shared_examples 'not affecting the VSTS Agent.Worker process or the launch agent' do
    it { is_expected.to_not create_launchd('create launchd service plist') }
    it { is_expected.to_not start_macosx_service('vsts agent launch agent') }
    it { is_expected.to_not enable_macosx_service('vsts agent launch agent') }
  end
end

describe 'vsts_agent_macos::bootstrap' do
  platform 'mac_os_x', '10.14'
  default_attributes['homebrew']['enable-analytics'] = false
  default_attributes['vsts_agent']['agent_name'] = 'com.microsoft.vsts-agent'

  describe 'VSTS Agent.Worker process running' do
    include_context 'with the VSTS Agent.Worker process running'
    it_behaves_like 'not affecting the VSTS Agent.Worker process or the launch agent'
  end
end
