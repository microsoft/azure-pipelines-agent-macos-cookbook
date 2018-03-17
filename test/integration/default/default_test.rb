describe user('vagrant') do
  it { should exist }
  its('uid') { should eq 501 }
  its('gid') { should eq 20 }
  its('home') { should eq '/Users/vagrant' }
end

describe launchd_service('vsts.agent.office') do
  it { should_not be_enabled }
  it { should_not be_installed }
  it { should_not be_running }
end

describe file('/Users/vagrant/vsts-agent/.env') do
  it { should exist }
  its('owner') { should eq 'vagrant' }
  its('content') { should match(/^LANG=en_US\.UTF\-8$/) }
  its('content') { should match %r{^VAGRANT_SERVER_URL=http:\/\/office\-infra\-boxes\.corp\.microsoft\.com$} }
end
