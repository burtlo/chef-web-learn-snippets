describe package 'postfix' do
  it { should be_installed }
end

describe service 'postfix' do
  it { should be_enabled }
  it { should be_running }
end

describe file '/etc/postfix/main.cf' do
  its('content') { should match /^mydomain = example.com$/ }
  its('content') { should match /^myorigin = example.com$/ }
end
