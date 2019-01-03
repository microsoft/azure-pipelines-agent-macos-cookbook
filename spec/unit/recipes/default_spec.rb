require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../../../libraries/agent'

include VstsAgentMacOS

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end
end

shared_context 'when converging the recipe' do
  default_attributes['homebrew']['enable-analytics'] = false

  shared_examples 'convergence without error' do
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

describe 'vsts_agent_macos::bootstrap' do
  platform 'mac_os_x', '10.14'
  default_attributes['homebrew']['enable-analytics'] = false
  default_attributes['vsts_agent']['agent_name'] = 'com.microsoft.vsts-agent'
  end

  before do
    allow(Chef::DataBagItem).to receive(:load).with('vsts', 'build_agent').and_return(personal_access_token: 'p9817234jhbasdfo87q234bnsadfasdf234')
  end

  let(:node_attributes) do
    { platform: 'mac_os_x', version: '10.13' }
  end

  describe 'bootstrapping the vsts agent' do
    include_context 'when converging the recipe'
    it_behaves_like 'convergence without error'
  end
end
