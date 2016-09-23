#
# Cookbook Name:: test_your_infra_code
# Recipe:: refactor-web-app
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

database_spec = '~/learn-chef/cookbooks/awesome_customers_rhel/spec/unit/recipes/database_spec.rb'
database_recipe = '~/learn-chef/cookbooks/awesome_customers_rhel/recipes/database.rb'
kitchen_yml = '~/learn-chef/cookbooks/awesome_customers_rhel/.kitchen.yml'
metadata_rb = '~/learn-chef/cookbooks/awesome_customers_rhel/metadata.rb'

directory '~/learn-chef/cookbooks/awesome_customers_rhel' do
  action :delete
  recursive true
end

with_snippet_options(lesson: 'refactor-the-web-application')

# 0. Get cookbook from github

with_snippet_options(step: 'git-clone-webapp-cookbook', cwd: '~/learn-chef/cookbooks') do

  snippet_execute 'git-clone-awesome_cusotmers' do
    command 'git clone https://github.com/learn-chef/awesome_customers_rhel.git'
    not_if 'stat ~/learn-chef/cookbooks/awesome_customers_rhel'
  end

end

# 1. Define what you'll refactor

# 2. Make the default ChefSpec test pass

with_snippet_options(step: 'make-the-default-spec-pass', cwd: '~/learn-chef/cookbooks/awesome_customers_rhel') do

  # Here's what the test looks like for the database recipe.
  snippet_code_block 'database_spec-0-rhel' do
    file_path database_spec
    content lazy { ::File.read(::File.expand_path(database_spec)) }
  end

  # Let's see what happens when we run the default ChefSpec tests.
  snippet_execute 'chef-exec-rspec-database-1' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
    ignore_failure true
  end

  # The default test fails – you see an error like this.
  snippet_execute 'chef-exec-rspec-database-2' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
    ignore_failure true
    excerpt_stdout ({
       from: /expected no Exception/,
       to: /and_return/
    })
    left_justify true
  end

  # The command the test fails on appears at the bottom of the database recipe.
  snippet_code_block 'database_spec-0-execute-rhel' do
    file_path database_recipe
    content lazy { ::File.read(::File.expand_path(database_recipe)).lines[56..59].join("\n") }
    write_system_file false
  end

  # If you were to run the ChefSpec test a second time, you would see a different database password in the output.
  snippet_execute 'chef-exec-rspec-database-3' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
    ignore_failure true
    excerpt_stdout ({
       from: /expected no Exception/,
       to: /and_return/
    })
    left_justify true
  end

  # Make your copy of database_spec.rb look like this.
  snippet_code_block 'database_spec-1-rhel' do
    file_path database_spec
    source_filename 'database_spec-1-rhel.rb'
  end

  # Notice that the command stub uses the node attribute values. It's stubbed to return false to tell ChefSpec that the execute resource should be run.
  snippet_code_block 'database_spec-1-before-rhel' do
    file_path database_spec
    content lazy { ::File.read(::File.expand_path(database_spec)).lines[4..6].join("\n") }
    write_system_file false
    left_justify true
  end

  # Now run ChefSpec.
  snippet_execute 'chef-exec-rspec-database-4' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
  end
end

# 3. Create pending tests for resources that uses node attributes

with_snippet_options(step: 'create-pending-tests', cwd: '~/learn-chef/cookbooks/awesome_customers_rhel') do

  # Recall that database.rb looks like this.
  snippet_code_block 'database-0-rhel' do
    file_path database_recipe
    content lazy { ::File.read(::File.expand_path(database_recipe)) }
  end

  # Modify database_spec.rb like this.
  snippet_code_block 'database_spec-2-rhel' do
    file_path database_spec
    source_filename 'database_spec-2-rhel.rb'
  end

  # Now run the tests.
  snippet_execute 'chef-exec-rspec-database-5' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
    ignore_failure true
  end

end

# 4. Write the pending tests

with_snippet_options(step: 'write-pending-tests', cwd: '~/learn-chef/cookbooks/awesome_customers_rhel') do

  ## it 'sets the MySQL service root password'

  # Replace the first pending test:
  cookbook_file ::File.join(Dir.tmpdir, 'database_spec-2-rhel.rb') do
    source 'database_spec-2-rhel.rb'
  end
  snippet_code_block 'database_spec-3-before-rhel' do
    file_path database_spec
    content lazy { ::File.read(::File.join(Dir.tmpdir, 'database_spec-2-rhel.rb')).lines[23..25].join("\n") }
    write_system_file false
    left_justify true
  end

  # with this test:
  snippet_code_block 'database_spec-3-rhel' do
    file_path database_spec
    source_filename 'database_spec-3-rhel.rb'
  end
  cookbook_file ::File.join(Dir.tmpdir, 'database_spec-3-rhel.rb') do
    source 'database_spec-3-rhel.rb'
  end
  snippet_code_block 'database_spec-3-after-rhel' do
    file_path database_spec
    content lazy { ::File.read(::File.join(Dir.tmpdir, 'database_spec-3-rhel.rb')).lines[23..26].join("\n") }
    write_system_file false
    left_justify true
  end

  # The with method validates the resource's properties. In this example, we're validating this resource:
  snippet_code_block 'database-mysql-service-excerpt' do
    file_path database_recipe
    content lazy { ::File.read(::File.expand_path(database_recipe)).lines[11..14].join("\n") }
    write_system_file false
  end

  # Run the tests.
  snippet_execute 'chef-exec-rspec-database-6' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
    ignore_failure true
  end

  ## it 'creates the database instance' and it 'creates the database user'

  # The next two resources to test look like this. These resources create the database instance and the user.
  snippet_code_block 'database-database-instance-user-excerpt' do
    file_path database_recipe
    content lazy { ::File.read(::File.expand_path(database_recipe)).lines[21..42].join("\n") }
    write_system_file false
  end

  # To define the connection info and implement the second and third tests, make database_spec.rb look like this.
  snippet_code_block 'database_spec-4-rhel' do
    file_path database_spec
    source_filename 'database_spec-4-rhel.rb'
  end

  # Now run the tests.
  snippet_execute 'chef-exec-rspec-database-7' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
    ignore_failure true
  end

  ## it 'seeds the database with a table and test data'

  # The final pending test verifies this execute resource:
  # (already computed previously...)

  # The value of #{create_tables_script_path} comes from here:
  snippet_code_block 'database-create_tables-excerpt' do
    file_path database_recipe
    content lazy { ::File.read(::File.expand_path(database_recipe)).lines[44..45].join("\n") }
    write_system_file false
  end

  # Modify database_spec.rb to include a let block that defines create_tables_script_path and to implement the final pending test. The entire file looks like this.
  snippet_code_block 'database_spec-5-rhel' do
    file_path database_spec
    source_filename 'database_spec-5-rhel.rb'
  end

  # Now run the tests.
  snippet_execute 'chef-exec-rspec-database-8' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
  end
end

# 5. Refactor the database configuration

with_snippet_options(step: 'refactor-the-database-configuration', cwd: '~/learn-chef/cookbooks/awesome_customers_rhel') do

  # Rewrite your database recipe like this. This revison replaces each node attribute with a variable and defines the connection information as a variable that can be reused.
  snippet_code_block 'database-1-rhel' do
    file_path database_recipe
    source_filename 'database-1-rhel.rb'
  end

  # Now rerun your ChefSpec tests to ensure that your resources are still correctly defined against your refacoring work.
  snippet_execute 'chef-exec-rspec-database-9' do
    command 'chef exec rspec --color spec/unit/recipes/database_spec.rb'
  end

end
