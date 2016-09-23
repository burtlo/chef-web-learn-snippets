require 'spec_helper'

describe 'awesome_customers_rhel::database' do
  context 'When all attributes are set, on CentOS 7.2.1511' do
    before do
      stub_command("mysql -h fake_host -u fake_admin -pfake_admin_password -D fake_database -e 'describe customers;'").and_return(false)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'centos', version: '7.2.1511') do |node|
        node.override['awesome_customers_rhel']['database']['root_password'] = 'fake_root_password'
        node.override['awesome_customers_rhel']['database']['admin_password'] = 'fake_admin_password'
        node.override['awesome_customers_rhel']['database']['dbname'] = 'fake_database'
        node.override['awesome_customers_rhel']['database']['host'] = 'fake_host'
        node.override['awesome_customers_rhel']['database']['root_username'] = 'fake_root'
        node.override['awesome_customers_rhel']['database']['admin_username'] = 'fake_admin'
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'sets the MySQL service root password'  do
      pending
    end

    it 'creates the database instance' do
      pending
    end

    it 'creates the database user' do
      pending
    end

    it 'seeds the database with a table and test data' do
      pending
    end
  end
end
