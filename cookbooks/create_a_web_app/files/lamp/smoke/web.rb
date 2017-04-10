describe package 'apache2' do
  it { should be_installed }
end

describe service 'apache2-default' do
  it { should be_enabled }
  it { should be_running }
end

describe command 'wget -qSO- --spider localhost' do
  its('stderr') { should match %r{HTTP/1\.1 200 OK} }
end

describe port 80 do
  it { should be_listening }
end
