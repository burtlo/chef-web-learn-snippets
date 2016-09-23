require 'spec_helper'

describe 'webserver_test::default' do
  let(:chef_run) do
    runner = ChefSpec::ServerRunner.new
    runner.converge(described_recipe)
  end

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it 'installs httpd' do
    expect(chef_run).to install_package 'httpd'
  end

  it 'enables the httpd service' do
    expect(chef_run).to enable_service 'httpd'
  end

  it 'starts the httpd service' do
    expect(chef_run).to start_service 'httpd'
  end
end
