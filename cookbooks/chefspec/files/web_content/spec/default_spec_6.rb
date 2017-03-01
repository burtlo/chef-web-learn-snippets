require 'spec_helper'

describe 'web_content::default' do
  context 'On Windows 2012 R2' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a directory with windows rights' do
      expect(chef_run).to create_directory('c:\inetpub\wwwroot')
        .with(
          rights: [{ permissions: :read, principals: 'IIS_IUSRS' }],
          recursive: true
        )
    end
  end
end
