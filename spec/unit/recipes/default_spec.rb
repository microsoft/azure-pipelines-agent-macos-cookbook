require 'spec_helper'
include VstsAgent::VstsHelpers

describe 'vsts_agent_macos::default' do
  context 'When all attributes are default, on macOS' do
    before do
      stub_data_bag_item('vsts', 'build_agent').and_return(
        account_url: 'https://foo.visualstudio.com',
        personal_access_token: 'bm40zjd64wz1i6uoeq7zpudi2emohp10imzzhf3a0r42co7v3h6n',
        agent_pool_name: 'bar'
      )
      allow_any_instance_of(Chef::Resource).to receive(:agent_needs_update?).and_return(true)
      allow_any_instance_of(Chef::Resource).to receive(:already_configured?).and_return(true)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'mac_os_x', version: '10.12')
      runner.converge(described_recipe)
    end

    it 'downloads the latest release' do
      expect(chef_run).to extract_tar_extract(latest_release)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
