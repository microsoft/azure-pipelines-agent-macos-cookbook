require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../../../libraries/agent'

include VstsAgentMacOS

at_exit { ChefSpec::Coverage.report! }

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.log_level = :error
end

shared_context 'when converging the recipe' do
  shared_examples 'convergence without error' do
    it 'converges successfully' do
      allow(Agent).to receive(:agent_data).and_return(false)
      chef_run.node.normal['vsts_agent']['data_bag'] = 'vsts'
      chef_run.node.normal['vsts_agent']['data_bag_item'] = 'build_agent'
      expect { chef_run }.to_not raise_error
    end
  end
end

describe 'vsts_agent_macos::bootstrap' do
  let(:chef_run) { ChefSpec::SoloRunner.new(node_attributes) }

  let(:node_attributes) do
    { platform: 'mac_os_x', version: '10.13' }
  end

  describe 'bootstrapping the vsts agent' do
    include_context 'when converging the recipe'
    it_behaves_like 'convergence without error'
  end
end
