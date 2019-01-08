require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../../../libraries/agent'

include VstsAgentMacOS

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end

shared_context 'with the VSTS launchd process listed and running' do
  before do
    allow(Agent).to receive(:launchd_list_output).and_return(["PID\tStatus\tLabel\n",
                                                              "240\t0\tcom.apple.trustd.agent\n",
                                                              "-\t0\tcom.apple.MailServiceAgent\n",
                                                              "-\t0\tcom.apple.mdworker.mail\n",
                                                              "-\t0\tcom.apple.mdworker.single.02000000-0000-0000-0000-000000000000\n",
                                                              "260\t0\tcom.apple.Finder\n",
                                                              "-\t0\tcom.apple.PackageKit.InstallStatus\n",
                                                              "19900\t0\tcom.microsoft.vsts-agent\n",
                                                              "365\t0\tcom.apple.iconservices.iconservicesagent\n",
                                                              "303\t0\tcom.apple.ContactsAgent\n",
                                                              "-\t0\tcom.apple.ManagedClientAgent.agent\n",
                                                              "-\t0\tcom.apple.screensharing.agent\n"])
  end
  shared_examples 'not affecting the VSTS agent process' do
    it { is_expected.to_not start_macosx_service('vsts agent launch agent') }
    it { is_expected.to_not enable_macosx_service('vsts agent launch agent') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

shared_context 'with the VSTS Agent.Worker process running' do
  before do
    allow(Agent).to receive(:worker_running?).and_return(true)
  end
  shared_examples 'not affecting the VSTS Agent.Worker process or the launch agent' do
    it { is_expected.to_not create_launchd('create launchd service plist') }
    it { is_expected.to_not start_macosx_service('vsts agent launch agent') }
    it { is_expected.to_not enable_macosx_service('vsts agent launch agent') }
  end
end

shared_context 'with the VSTS launchd process listed but not running' do
  before do
    allow(Agent).to receive(:launchd_list_output).and_return(["PID\tStatus\tLabel\n",
                                                              "240\t0\tcom.apple.trustd.agent\n",
                                                              "-\t0\tcom.apple.MailServiceAgent\n",
                                                              "-\t0\tcom.apple.mdworker.mail\n",
                                                              "-\t0\tcom.apple.mdworker.single.02000000-0000-0000-0000-000000000000\n",
                                                              "260\t0\tcom.apple.Finder\n",
                                                              "-\t0\tcom.apple.PackageKit.InstallStatus\n",
                                                              "-\t0\tcom.microsoft.vsts-agent\n",
                                                              "365\t0\tcom.apple.iconservices.iconservicesagent\n",
                                                              "303\t0\tcom.apple.ContactsAgent\n",
                                                              "-\t0\tcom.apple.ManagedClientAgent.agent\n",
                                                              "-\t0\tcom.apple.screensharing.agent\n"])
  end
  shared_examples 'starting but not enabling the VSTS agent process' do
    it { is_expected.to start_macosx_service('vsts agent launch agent') }
    it { is_expected.to_not enable_macosx_service('vsts agent launch agent') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

shared_context 'with the VSTS launchd process not listed and not running' do
  before do
    allow(Agent).to receive(:launchd_list_output).and_return(["PID\tStatus\tLabel\n",
                                                              "-\t0\tcom.google.Chrome.22128\n",
                                                              "772\t0\tcom.google.Chrome.18908\n",
                                                              "-\t0\tcom.apple.SafariHistoryServiceAgent\n",
                                                              "502\t0\tcom.apple.Finder\n",
                                                              "554\t0\tcom.apple.homed\n",
                                                              "651\t0\tcom.apple.SafeEjectGPUAgent\n",
                                                              "-\t0\tcom.apple.quicklook\n",
                                                              "-\t0\tcom.apple.parentalcontrols.check\n",
                                                              "-\t0\tcom.apple.PackageKit.InstallStatus\n",
                                                              "555\t0\tcom.apple.mediaremoteagent\n",
                                                              "-\t0\tcom.apple.FontWorker\n",
                                                              "521\t0\tcom.apple.bird\n"])
  end

  shared_examples 'starting and enabling the VSTS agent process' do
    it { is_expected.to start_macosx_service('vsts agent launch agent') }
    it { is_expected.to enable_macosx_service('vsts agent launch agent') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

describe 'vsts_agent_macos::bootstrap' do
  platform 'mac_os_x', '10.14'
  default_attributes['homebrew']['enable-analytics'] = false
  default_attributes['vsts_agent']['agent_name'] = 'com.microsoft.vsts-agent'

  before do
    allow(Chef::DataBagItem).to receive(:load).with('vsts', 'build_agent').and_return(personal_access_token: 'p9817234jhbasdfo87q234bnsadfasdf234')
  end

  describe 'VSTS launchd process already listed and running' do
    include_context 'with the VSTS launchd process listed and running'
    it_behaves_like 'not affecting the VSTS agent process'
  end

  describe 'VSTS Agent.Worker process running' do
    include_context 'with the VSTS Agent.Worker process running'
    it_behaves_like 'not affecting the VSTS Agent.Worker process or the launch agent'
  end

  # describe 'VSTS launchd process listed but not currently running' do
  #   include_context 'with the VSTS launchd process listed but not running'
  #   it_behaves_like 'starting but not enabling the VSTS agent process'
  # end

  # describe 'VSTS launchd process not listed and presumed not running' do
  #   include_context 'with the VSTS launchd process not listed and not running'
  #   it_behaves_like 'starting and enabling the VSTS agent process'
  # end
end
