#
# Cookbook:: create_a_web_app
# Recipe:: lamp_customers
#
# Copyright:: 2017, The Authors, All Rights Reserved.

scenario = node['scenarios']['lamp']

cookbook = scenario['wrapper_cookbook']
drivers = scenario['drivers']
platform = scenario['platform']

with_snippet_options(platform: platform)

drivers.each do |driver|

  with_snippet_options(
    virtualization: driver,
    lesson: "create-the-customers-app-#{platform}-#{driver}",
    cwd: '~') do

      # clean up any previous files
      directory "delete-lamp_customers-dir-#{platform}-#{driver}" do
        path ::File.expand_path('~/learn-chef/cookbooks/lamp_customers')
        action :delete
        recursive true
      end

      with_snippet_options(step: "create-#{cookbook}-cookbook-#{platform}-#{driver}") do
        snippet_execute "cd-learn-chef-#{platform}-#{driver}-2" do
          command 'cd ~/learn-chef'
          cwd '~/learn-chef/cookbooks/lamp'
        end
        # chef generate cookbook cookbooks/lamp_customers
        snippet_execute "chef-generate-cookbook-lamp_customers#{platform}-#{driver}" do
          command 'chef generate cookbook cookbooks/lamp_customers'
          cwd '~/learn-chef'
        end
        snippet_execute "cd-lamp_customers-#{platform}-#{driver}" do
          command 'cd ~/learn-chef/cookbooks/lamp_customers'
          cwd '~/learn-chef'
        end
        snippet_code_block "berkfile-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/Berksfile"
          source_filename "#{cookbook}/Berksfile"
          language 'ruby'
        end
        snippet_code_block "metadata-#{platform}-#{driver}-4" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
          source_filename "#{cookbook}/metadata/metadata-lamp.rb"
          language 'ruby'
        end
        snippet_code_block "run-lamp-recipe-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
          source_filename "#{cookbook}/recipes/default-lamp.rb"
        end
        snippet_code_block "kitchen-yml-#{platform}-#{driver}-3" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"
          source_filename "#{cookbook}/kitchen/kitchen.yml"
        end
        snippet_execute "kitchen-converge-#{platform}-#{driver}-5" do
          command 'kitchen converge'
          cwd '~/learn-chef/cookbooks/lamp_customers'
          truncate_stdout [
            {skip: 0.03, take: 0.93, action: :drop}
          ]
        end
      end

      with_snippet_options(step: "add-database-table-#{platform}-#{driver}") do
        snippet_execute "chef-generate-file-create-tables-#{platform}-#{driver}" do
          command 'chef generate file create-tables.sql'
          cwd '~/learn-chef/cookbooks/lamp_customers'
        end
        snippet_code_block "create-tables-sql-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/files/default/create-tables.sql"
          source_filename "#{cookbook}/files/create-tables.sql"
        end
        snippet_code_block "run-database-script-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
          source_filename "#{cookbook}/recipes/default-db.rb"
        end
      end

      with_snippet_options(step: "add-homepage-#{platform}-#{driver}") do
        snippet_execute "chef-generate-template-index-#{platform}-#{driver}" do
          command 'chef generate template index.php'
          cwd '~/learn-chef/cookbooks/lamp_customers'
        end
        snippet_code_block "index-php-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/templates/index.php.erb"
          source_filename "#{cookbook}/templates/index.php.erb"
          language 'html'
        end
        snippet_code_block "index-php-excerpt-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/templates/index.php.erb"
          source_filename "#{cookbook}/templates/index-excerpt.php.erb"
          language 'php'
          write_system_file false
        end
        snippet_code_block "run-php-template-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
          source_filename "#{cookbook}/recipes/default-php.rb"
        end
      end

      with_snippet_options(step: "add-node-attributes-#{platform}-#{driver}") do
        snippet_code_block "lamp-attributes-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/lamp/attributes/default.rb"
          write_system_file false
          content lazy {
            ::File.read(::File.expand_path("~/learn-chef/cookbooks/lamp/attributes/default.rb"))
          }
        end
        snippet_execute "chef-generate-attribute-#{platform}-#{driver}-2" do
          command 'chef generate attribute default'
          cwd '~/learn-chef/cookbooks/lamp_customers'
        end
        snippet_code_block "attribute-#{platform}-#{driver}-4" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/attributes/default.rb"
          source_filename "#{cookbook}/attributes/attributes-1.rb"
        end
      end

      with_snippet_options(step: "apply-cookbook-#{platform}-#{driver}") do
        snippet_execute "kitchen-converge-#{platform}-#{driver}-6" do
          command 'kitchen converge'
          cwd '~/learn-chef/cookbooks/lamp_customers'
          truncate_stdout [
            {skip: 0.15, take: 0.69, action: :drop}
          ]
        end
      end

      with_snippet_options(step: "verify-customers-configuration-#{platform}-#{driver}") do
        snippet_code_block "inspec-default-#{platform}-#{driver}-2" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/test/smoke/default/default_test.rb"
          source_filename "#{cookbook}/smoke/default_test.rb"
        end
        snippet_execute "kitchen-verify-customers-#{platform}-#{driver}-1" do
          command 'kitchen verify'
          cwd '~/learn-chef/cookbooks/lamp_customers'
        end
        snippet_execute "kitchen-test-#{platform}-#{driver}-2" do
          command 'kitchen test'
          cwd '~/learn-chef/cookbooks/lamp_customers'
          truncate_stdout [
            {skip: 0.02, take: 0.94, action: :drop}
          ]
        end
      end
    end
  end
