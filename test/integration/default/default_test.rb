describe user('vagrant') do
  it { should exist }
  its('uid') { should eq 501 }
  its('gid') { should eq 20 }
  its('home') { should eq '/Users/vagrant' }
end

describe launchd_service('com.microsoft.vsts-agent') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe file('/Users/vagrant/vsts-agent/.credentials') do
  it { should exist }
  its('owner') { should eq 'vagrant' }
end

describe file('/Users/vagrant/vsts-agent/.path') do
  it { should exist }
  its('owner') { should eq 'vagrant' }
  its('content') { should match %r{/usr/local/bin} }
  its('content') { should match %r{/usr/local/sbin} }
  its('content') { should match %r{/usr/bin} }
  its('content') { should match %r{/usr/sbin} }
end

describe file('/Users/vagrant/vsts-agent/.agent') do
  it { should exist }
  its('owner') { should eq 'vagrant' }
end

describe file('/Users/vagrant/vsts-agent/.env') do
  it { should exist }
  its('owner') { should eq 'vagrant' }
  its('content') { should match(/^LANG=en_US\.UTF\-8$/) }
  its('content') { should match %r{^VAGRANT_SERVER_URL=http:\/\/office\-infra\-boxes\.corp\.microsoft\.com$} }
end
