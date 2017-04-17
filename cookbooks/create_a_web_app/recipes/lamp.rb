#
# Cookbook:: create_a_web_app
# Recipe:: lamp
#
# Copyright:: 2017, The Authors, All Rights Reserved.

scenario = node['scenarios']['lamp']

cookbook = scenario['cookbook']
drivers = scenario['drivers']
platform = scenario['platform']

with_snippet_options(platform: platform)

drivers.each do |driver|

  with_snippet_options(
    virtualization: driver,
    lesson: "create-the-cookbook-#{platform}-#{driver}",
    cwd: '~') do

      # clean up any previous files
      directory "delete-cookbooks-dir-#{platform}-#{driver}" do
        path ::File.expand_path('~/learn-chef/cookbooks')
        action :delete
        recursive true
      end

      with_snippet_options(step: "create-the-cookbook-#{platform}-#{driver}") do
        # cd ~/learn-chef
        snippet_execute "cd-learn-chef-#{platform}-#{driver}-1" do
          command 'cd ~/learn-chef'
          cwd '~'
        end

        # mkdir cookbooks
        snippet_execute "mkdir-cookbooks-#{platform}-#{driver}" do
          command 'mkdir cookbooks'
          not_if 'stat ~/learn-chef/cookbooks'
          cwd '~/learn-chef'
        end

        # chef generate cookbook cookbooks/lamp
        snippet_execute "chef-generate-cookbook-lamp-#{platform}-#{driver}" do
          command 'chef generate cookbook cookbooks/lamp'
          cwd '~/learn-chef'
        end
      end

      with_snippet_options(step: "apt-cache-#{platform}-#{driver}") do
        snippet_code_block "update-apt-cache-#{platform}-#{driver}" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
          source_filename "#{cookbook}/recipes/default-apt.rb"
        end
      end

      with_snippet_options(step: "apply-cookbook-#{platform}-#{driver}") do
        snippet_code_block "kitchen-yml-#{platform}-#{driver}-1" do
          file_path "~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"
          source_filename "#{cookbook}/kitchen/kitchen-1.yml"
        end

        snippet_execute "cd-learn-chef-cookbooks-#{cookbook}-#{platform}-#{driver}-1" do
          command 'cd ~/learn-chef/cookbooks/lamp'
          cwd '~/learn-chef'
        end

        snippet_execute "kitchen-list-#{platform}-#{driver}-1" do
          command 'kitchen list'
          cwd '~/learn-chef/cookbooks/lamp'
        end

        snippet_execute "kitchen-converge-#{platform}-#{driver}-1" do
          command 'kitchen converge'
          cwd '~/learn-chef/cookbooks/lamp'
          truncate_stdout [
            {skip: 0.2, take: 0.35, action: :drop}
          ]
        end

        snippet_execute "kitchen-exec-whoami-#{platform}-#{driver}" do
          command 'kitchen exec -c whoami'
          cwd '~/learn-chef/cookbooks/lamp'
        end
      end
    end

    # Write config file while we have an instance running.
    platform_display_name = case platform
    when 'ubuntu'
      'Ubuntu 14.04'
    when 'windows'
      "Windows Server 2012 R2"
    end
    vagrant_ubuntu_version = '/vagrant/vagrant-ubuntu.version'
    virtualbox_ubuntu_version = '/vagrant/virtualbox-ubuntu.version'
    snippet_config "create-a-web-app-cookbook-#{platform}-#{driver}" do
      tutorial 'create-a-web-app-cookbook'
      platform platform
      variables lazy {
        ({
          :platform_display_name => platform_display_name,
          :vagrant_ubuntu_version => ::File.read(vagrant_ubuntu_version),
          :virtualbox_ubuntu_version => ::File.read(virtualbox_ubuntu_version),
          :chef_client_version => `cd #{::File.expand_path('~/learn-chef')}/cookbooks/#{cookbook} && kitchen exec -c 'chef-client --version'`.split('\n').grep(/Chef: (\d+\.\d+\.\d+)$/){ $1 }[0],
        })
      }
    end

    with_snippet_options(
      virtualization: driver,
      lesson: "configure-apache-#{platform}-#{driver}",
      cwd: '~') do
        with_snippet_options(step: "reference-the-httpd-cookbook-#{platform}-#{driver}") do
          snippet_code_block "metadata-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
            source_filename "#{cookbook}/metadata/metadata-http.rb"
          end

          snippet_execute "knife-supermarket-show-httpd-#{platform}-#{driver}-1" do
            command 'knife supermarket show httpd | grep latest_version'
            cwd '~/learn-chef/cookbooks/lamp'
          end
        end

        with_snippet_options(step: "specify-the-document-root-#{platform}-#{driver}") do
          snippet_execute "chef-generate-attribute-#{platform}-#{driver}-1" do
            command 'chef generate attribute default'
            cwd '~/learn-chef/cookbooks/lamp'
          end
          snippet_code_block "attribute-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/attributes/default.rb"
            source_filename "#{cookbook}/attributes/attributes-1.rb"
          end
        end

        with_snippet_options(step: "create-apache-config-#{platform}-#{driver}") do
          snippet_execute "chef-generate-template-#{platform}-#{driver}-1" do
            command 'chef generate template default.conf'
            cwd '~/learn-chef/cookbooks/lamp'
          end
          snippet_code_block "template-default-conf-#{platform}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/templates/default.conf.erb"
            source_filename "#{cookbook}/templates/default.conf.erb"
            language 'ruby'
          end
        end

        with_snippet_options(step: "create-web-recipe-#{platform}-#{driver}") do
          snippet_execute "chef-generate-recipe-web-#{platform}-#{driver}" do
            command 'chef generate recipe web'
            cwd '~/learn-chef/cookbooks/lamp'
          end
          snippet_code_block "recipe-web-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"
            source_filename "#{cookbook}/recipes/web-docroot.rb"
          end
          snippet_code_block "recipe-web-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"
            source_filename "#{cookbook}/recipes/web-httpd.rb"
          end
        end

        with_snippet_options(step: "run-web-recipe-#{platform}-#{driver}") do
          snippet_code_block "run-web-recipe-#{platform}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
            source_filename "#{cookbook}/recipes/default-web.rb"
          end
        end

        with_snippet_options(step: "apply-the-apache-configuration-#{platform}-#{driver}") do
          snippet_execute "kitchen-converge-#{platform}-#{driver}-2" do
            command 'kitchen converge'
            cwd '~/learn-chef/cookbooks/lamp'
            truncate_stdout [
              {skip: 0.04, take: 0.91, action: :drop}
            ]
          end
          snippet_code_block "review-kitchen-yml-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"
            write_system_file false
            content lazy {
              ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"))
            }
          end
          snippet_execute "kitchen-exec-wget-#{platform}-#{driver}-1" do
            command "kitchen exec -c 'wget -qO- localhost'"
            cwd '~/learn-chef/cookbooks/lamp'
          end
        end

        with_snippet_options(step: "verify-the-apache-configuration-#{platform}-#{driver}") do
          snippet_code_block "inspec-web-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/test/smoke/default/web_test.rb"
            source_filename "#{cookbook}/smoke/web.rb"
          end
          snippet_code_block "inspec-default-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/test/smoke/default/default_test.rb"
            source_filename "#{cookbook}/smoke/default_test.rb"
          end
          snippet_code_block "review-kitchen-yml-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"
            write_system_file false
            content lazy {
              ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"))
            }
          end
          snippet_execute "kitchen-verify-apache-#{platform}-#{driver}-1" do
            command 'kitchen verify'
            cwd '~/learn-chef/cookbooks/lamp'
          end
        end
    end

    with_snippet_options(
      virtualization: driver,
      lesson: "configure-mysql-#{platform}-#{driver}",
      cwd: '~') do
        with_snippet_options(step: "reference-the-mysql-cookbook-#{platform}-#{driver}") do
          snippet_code_block "metadata-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
            source_filename "#{cookbook}/metadata/metadata-mysql.rb"
          end
        end

        with_snippet_options(step: "create-database-recipe-#{platform}-#{driver}") do
          snippet_execute "chef-generate-recipe-database-#{platform}-#{driver}" do
            command 'chef generate recipe database'
            cwd '~/learn-chef/cookbooks/lamp'
          end
        end

        with_snippet_options(step: "create-a-data-bag-#{platform}-#{driver}") do
          snippet_execute "mkdir-test-fixtures-#{platform}-#{driver}" do
            command 'mkdir -p test/fixtures/default/data_bags/passwords'
            cwd '~/learn-chef/cookbooks/lamp'
          end
          snippet_code_block "data-bag-item-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/test/fixtures/default/data_bags/passwords/mysql.json"
            source_filename "#{cookbook}/passwords/mysql-1.json"
          end
          snippet_code_block "kitchen-yml-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"
            source_filename "#{cookbook}/kitchen/kitchen-2.yml"
          end
        end

        with_snippet_options(step: "configure-mysql-#{platform}-#{driver}") do
          snippet_code_block "recipe-database-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/database.rb"
            source_filename "#{cookbook}/recipes/database-mysql.rb"
          end
        end

        with_snippet_options(step: "create-database-instance-#{platform}-#{driver}") do
          snippet_code_block "metadata-#{platform}-#{driver}-3" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
            source_filename "#{cookbook}/metadata/metadata-mysql-gem-database.rb"
          end
          snippet_code_block "attribute-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/attributes/default.rb"
            source_filename "#{cookbook}/attributes/attributes-2.rb"
          end
          snippet_code_block "attribute-#{platform}-#{driver}-3" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/attributes/default.rb"
            source_filename "#{cookbook}/attributes/attributes-3.rb"
          end
          snippet_code_block "data-bag-item-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/test/fixtures/default/data_bags/passwords/mysql.json"
            source_filename "#{cookbook}/passwords/mysql-2.json"
          end
          snippet_code_block "recipe-database-#{platform}-#{driver}-2" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/database.rb"
            source_filename "#{cookbook}/recipes/database-mysql-gem.rb"
          end
          snippet_code_block "recipe-database-#{platform}-#{driver}-3" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/database.rb"
            source_filename "#{cookbook}/recipes/database-mysql-database.rb"
          end
          snippet_code_block "recipe-database-#{platform}-#{driver}-4" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/database.rb"
            source_filename "#{cookbook}/recipes/database-mysql-gem-database.rb"
          end
        end

        with_snippet_options(step: "run-database-recipe-#{platform}-#{driver}") do
          snippet_code_block "run-database-recipe-#{platform}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
            source_filename "#{cookbook}/recipes/default-database.rb"
          end
        end

        with_snippet_options(step: "apply-the-mysql-configuration-#{platform}-#{driver}") do
          snippet_execute "kitchen-converge-#{platform}-#{driver}-3" do
            command 'kitchen converge'
            cwd '~/learn-chef/cookbooks/lamp'
            truncate_stdout [
              {skip: 0.09, take: 0.81, action: :drop}
            ]
          end
        end

        with_snippet_options(step: "verify-the-mysql-configuration-#{platform}-#{driver}") do
          snippet_execute "kitchen-exec-cat-config-#{platform}-#{driver}" do
            command "kitchen exec -c 'sudo cat /etc/mysql-default/my.cnf'"
            cwd '~/learn-chef/cookbooks/lamp'
          end
          snippet_execute "kitchen-exec-show-databases-#{platform}-#{driver}" do
            command %Q{kitchen exec -c "mysql -h 127.0.0.1 -uroot -pfakerootpassword -s -e 'show databases;'"}
            cwd '~/learn-chef/cookbooks/lamp'
          end
          snippet_code_block "inspec-database-#{platform}-#{driver}-1" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/test/smoke/default/database_test.rb"
            source_filename "#{cookbook}/smoke/database.rb"
          end
          snippet_execute "kitchen-verify-database-#{platform}-#{driver}-1" do
            command 'kitchen verify'
            cwd '~/learn-chef/cookbooks/lamp'
          end
        end
    end

    with_snippet_options(
      virtualization: driver,
      lesson: "configure-php-#{platform}-#{driver}",
      cwd: '~') do
        with_snippet_options(step: "install-php-#{platform}-#{driver}") do
          snippet_code_block "recipe-web-#{platform}-#{driver}-3" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"
            write_system_file false
            content lazy {
              ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"))
            }
          end
          snippet_code_block "recipe-web-#{platform}-#{driver}-4" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"
            source_filename "#{cookbook}/recipes/web-mod_php5.rb"
          end
          snippet_code_block "recipe-web-#{platform}-#{driver}-5" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"
            source_filename "#{cookbook}/recipes/web-php5-mysql.rb"
          end
          snippet_code_block "recipe-web-#{platform}-#{driver}-6" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/web.rb"
            source_filename "#{cookbook}/recipes/web-php.rb"
          end
        end

        with_snippet_options(step: "apply-the-php-configuration-#{platform}-#{driver}") do
          snippet_execute "kitchen-converge-#{platform}-#{driver}-4" do
            command 'kitchen converge'
            cwd '~/learn-chef/cookbooks/lamp'
            truncate_stdout [
              {skip: 0.17, take: 0.64, action: :drop}
            ]
          end

          snippet_execute "kitchen-test-#{platform}-#{driver}-1" do
            command 'kitchen test'
            cwd '~/learn-chef/cookbooks/lamp'
            truncate_stdout [
              {skip: 0.03, take: 0.93, action: :drop}
            ]
          end
        end
    end
  end
