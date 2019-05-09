require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'

require_relative '../../../libraries/agent'

include AzurePipelines

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.log_level = :error
end

shared_context 'agent is running a job' do
  include ChefVault::TestFixtures.rspec_shared_context

  before do
    stub_data_bag_item('azure_pipelines', 'build_agent').and_return('personal_access_token' => 'p9817234jhbasdfo87q234bnsadfasdf234')
    allow(Agent).to receive(:worker_running?).and_return true
  end

  shared_examples 'not affecting the listener or worker processes' do
    it { is_expected.to_not create_launchd('create launchd service plist') }
  end
end

shared_context 'agent is idle' do
  include ChefVault::TestFixtures.rspec_shared_context

  before do
    stub_data_bag_item('azure_pipelines', 'build_agent').and_return('personal_access_token' => 'p9817234jhbasdfo87q234bnsadfasdf234')
    allow(Agent).to receive(:worker_running?).and_return false
  end

  shared_examples 'creating the launch daemon, enabling, and starting the service' do
    it { is_expected.to create_launchd('create launchd service plist') }
    it { expect(chef_run.template('create environment file')).to notify('macosx_service[azure-pipelines-agent]').to(:restart) }
  end
end

describe 'azure_pipelines_agent_macos::bootstrap' do
  platform 'mac_os_x', '10.14'

  describe 'bootstrap when running a job' do
    include_context 'agent is running a job'
    it_behaves_like 'not affecting the listener or worker processes'
  end

  describe 'bootstrap when idle' do
    include_context 'agent is idle'
    it_behaves_like 'creating the launch daemon, enabling, and starting the service'
  end
end
