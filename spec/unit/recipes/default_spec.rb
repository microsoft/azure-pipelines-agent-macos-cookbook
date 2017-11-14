require 'spec_helper'
include VstsAgent::VstsHelpers
include Chef::DSL::Recipe

describe 'vsts_agent_macos::vsts_agent' do
  before do
    stub_data_bag_item('vsts', 'build_agent').and_return(
      account_url: 'https://foo.visualstudio.com',
      personal_access_token: 'bm40zjd64wz1i6uoeq7zpudi2emohp10imzzhf3a0r42co7v3h6n',
      agent_pool_name: 'bar'
    )
  end

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(platform: 'mac_os_x', version: '10.12')
    runner.converge(described_recipe)
  end

  context 'When the agent has already been configured, but the agent needs to be updated' do
    before do
      allow_any_instance_of(Chef::Resource).to receive(:agent_needs_update?).and_return(true)
    end

    xit 'the latest release is received.' do
      allow_any_instance_of(Chef::Resource).to receive(:latest_release).and_return('https://github.com/Foo/bar/releases/download/v2.124.0/bar-x64-2.124.0.tar.gz')
      expect_any_instance_of(Chef::Resource).to receive(:latest_release)
    end

    xit 'the latest release is downloaded and extracted.' do
      expect(chef_run).to extract_tar_extract(latest_release)
    end

    xit 'the agent_needs_update? method is used' do
      expect_any_instance_of(Chef::Resource).to receive(:agent_needs_update?)
    end
  end

  context 'When the agent has already been configured and the agent does not need to be updated' do
    before do
      allow_any_instance_of(Chef::Resource::ActionClass).to receive(:needs_configuration?).and_return(false)
      allow_any_instance_of(Chef::Resource::ActionClass).to receive(:agent_needs_update?).and_return(false)
    end

    xit 'the tar is not downloaded' do
      expect(chef_run).to_not extract_tar_extract(latest_release)
    end
  end

  context 'When the service is running' do
    before do
      allow_any_instance_of(Chef::Resource).to receive(:service_started?).and_return(true)
    end

    xit 'does not try and start the service' do
      expect(chef_run).to_not run_execute('start service')
    end
  end
end
