describe user('vagrant') do
  it { should exist }
  its('uid') { should eq 501 }
  its('gid') { should eq 20 }
  its('home') { should eq '/Users/vagrant' }
end

describe launchd_service('vsts.agent.office') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end
