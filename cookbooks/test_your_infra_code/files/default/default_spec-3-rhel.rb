require 'spec_helper'

describe 'webserver_test::default' do
  context 'when run on CentOS 7.2.1511' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.2.1511')
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

  context 'when run on Ubuntu 14.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs apache2' do
      expect(chef_run).to install_package 'apache2'
    end

    it 'enables the apache2 service' do
      expect(chef_run).to enable_service 'apache2'
    end

    it 'starts the apache2 service' do
      expect(chef_run).to start_service 'apache2'
    end
  end
end
