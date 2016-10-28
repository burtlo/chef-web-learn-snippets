#
# Cookbook Name:: local_development
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(
  tutorial: 'local-development',
  platform: node['snippets']['node_platform'],
  virtualization: 'vagrant',
  prompt_character: node['snippets']['prompt_character']
  ) do

  include_recipe 'manage_a_node::workstation'

  shell = node['platform'] == 'windows' ? 'ps' : nil
  with_snippet_options(
    lesson: 'set-up-your-workstation',
    shell: shell,
    cwd: '~',
    step: 'set-up-your-working-directory') do

    snippet_execute 'mkdir-learn-chef-cookbooks' do
      command 'mkdir ~/learn-chef/cookbooks'
      not_if 'stat ~/learn-chef/cookbooks'
    end

    snippet_execute 'cd-learn-chef-cookbooks' do
      command 'cd ~/learn-chef/cookbooks'
    end
  end

  node['scenarios'].each do |scenario|

    drivers = Array(scenario['drivers'])
    cookbook = scenario['cookbook']
    platform = scenario['platform']

    with_snippet_options(platform: platform)

    drivers.each do |driver|
      with_snippet_options(
        virtualization: driver,
        lesson: "apply-the-cookbook-#{cookbook}-#{driver}",
        cwd: '~/learn-chef/cookbooks') do

        # Ensure the cookbook does not exist.
        directory "rm-#{cookbook}-#{driver}" do
          path "~/learn-chef/cookbooks/#{cookbook}"
          action :delete
          recursive true
        end

        # Clone the cookbook.
        with_snippet_options(step: "get-the-#{cookbook}-cookbook-#{driver}") do
          snippet_execute "git-clone-#{cookbook}-#{driver}" do
            command "git clone https://github.com/learn-chef/#{cookbook}.git"
            not_if "stat ~/learn-chef/cookbooks/#{cookbook}"
          end

          snippet_execute "cd-cookbooks-#{cookbook}-#{driver}" do
            command "cd ~/learn-chef/cookbooks/#{cookbook}"
          end
        end

        with_snippet_options(step: "understand-kitchen-yml-#{cookbook}-#{driver}") do
          snippet_code_block "kitchen-yml-#{cookbook}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml"
            content lazy { ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/.kitchen.yml")) }
            write_system_file false
          end
        end

        # Create the Test Kitchen instance
        # kitchen list
        # kitchen create
        # kitchen list
        with_snippet_options(step: "create-#{cookbook}-#{driver}", cwd: "~/learn-chef/cookbooks/#{cookbook}") do
          snippet_execute "kitchen-list-#{cookbook}-#{driver}-1" do
            command "kitchen list"
          end

          snippet_execute "kitchen-create-#{cookbook}-#{driver}-1" do
            command "kitchen create"
          end

          snippet_execute "kitchen-list-#{cookbook}-#{driver}-2" do
            command "kitchen list"
          end
        end

        # Apply the cookbook
        # kitchen converge
        # echo $?
        # kitchen list
        # kitchen converge
        with_snippet_options(step: "apply-#{cookbook}-#{driver}", cwd: "~/learn-chef/cookbooks/#{cookbook}") do
          snippet_execute "kitchen-converge-#{cookbook}-#{driver}-1" do
            command "kitchen converge"
            remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/, /Reading database/]
          end

          snippet_execute "echo-money-#{cookbook}-#{driver}-1" do
            command "echo $?"
          end

          snippet_execute "kitchen-list-#{cookbook}-#{driver}-3" do
            command "kitchen list"
          end

          snippet_execute "kitchen-converge-#{cookbook}-#{driver}-2" do
            command "kitchen converge"
            remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/, /Reading database/]
          end
        end

        # Verify your Test Kitchen instance
        # kitchen ~login~ exec
        with_snippet_options(step: "verify-#{cookbook}-#{driver}", cwd: "~/learn-chef/cookbooks/#{cookbook}") do
          snippet_execute "kitchen-exec-#{cookbook}-#{driver}-1" do
            command "kitchen exec -c 'curl localhost'"
          end
        end

        # Write config file while we have an instance running.
        platform_display_name = case platform
        when 'rhel'
          'CentOS 7.2'
        when 'ubuntu'
          'Ubuntu 14.04'
        when 'windows'
          "Windows Server 2012 R2"
        end
        vagrant_ubuntu_version = '/vagrant/vagrant-ubuntu.version'
        virtualbox_ubuntu_version = '/vagrant/virtualbox-ubuntu.version'
        snippet_config "manage-a-node-#{platform}" do
          tutorial 'local-development'
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

        # Delete the Test Kitchen instance
        # kitchen destroy
        # kitchen list
        with_snippet_options(step: "delete-#{cookbook}-#{driver}", cwd: "~/learn-chef/cookbooks/#{cookbook}") do
          snippet_execute "kitchen-destroy-#{cookbook}-#{driver}-1" do
            command "kitchen destroy"
          end

          snippet_execute "kitchen-list-#{cookbook}-#{driver}-4" do
            command "kitchen list"
          end
        end
      end

      with_snippet_options(
        virtualization: driver,
        lesson: "resolve-a-failure-#{cookbook}-#{driver}",
        cwd: '~/learn-chef/cookbooks') do

        with_snippet_options(cwd: "~/learn-chef/cookbooks/#{cookbook}", step: 'set-web-content-owner') do
          # Show current recipe.
          snippet_code_block "initial-default-recipe-#{cookbook}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
            content lazy {
              ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"))
            }
          end

          # Update default recipe.
          snippet_code_block "add-web-user-err-#{cookbook}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
            source_filename "#{cookbook}/add-web-user-err.rb"
          end

          # TODO: Remember to mention we don't need to update metadata.

          # kitchen converge
          snippet_execute "kitchen-converge-#{cookbook}-#{driver}-3" do
            command "kitchen converge"
            remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/, /Reading database/]
            ignore_failure true # we expect to fail
            write_exitstatus true
          end

          snippet_execute "echo-money-#{cookbook}-#{driver}-2" do
            command "echo $?"
          end

          snippet_execute "kitchen-list-#{cookbook}-#{driver}-5" do
            command "kitchen list"
          end

          #### Resolve

          # Update default recipe.
          snippet_code_block "add-web-user-fix-#{cookbook}-#{driver}" do
            file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
            source_filename "#{cookbook}/add-web-user-fix.rb"
          end

          # kitchen converge
          snippet_execute "kitchen-converge-#{cookbook}-#{driver}-4" do
            command "kitchen converge"
            remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/, /Reading database/]
          end

          # kitchen exec
          snippet_execute "kitchen-exec-#{cookbook}-#{driver}-2" do
            command "kitchen exec -c 'curl localhost'"
          end
          snippet_execute "kitchen-exec-#{cookbook}-#{driver}-3" do
            command "kitchen exec -c 'stat /var/www/html/index.html'"
          end

        end
      end

    end
  end
end
