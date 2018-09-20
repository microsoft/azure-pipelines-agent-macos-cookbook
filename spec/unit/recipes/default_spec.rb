require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../../../libraries/agent'

include VstsAgentMacOS

at_exit { ChefSpec::Coverage.report! }

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.log_level = :trace
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
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(node_attributes)
    runner.converge(described_recipe)
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
