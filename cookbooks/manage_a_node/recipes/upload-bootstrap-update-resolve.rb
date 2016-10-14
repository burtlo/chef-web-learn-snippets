#
# Cookbook Name:: manage_a_node
# Recipe:: upload-bootstrap-update-resolve
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

node.run_state['bootstrap_command'] = {}
node.run_state['knife_ssh_command'] = {}

# Ensure cookbooks do not exist locally.
directory ::File.expand_path('~/learn-chef/cookbooks') do
  action :delete
  recursive true
end

node['nodes'].each do |n|

  # Setup
  ##################

  node_platform = n['platform']
  node_name = n['name']
  cookbook = n['cookbook']
  template_filename = node_platform == 'windows' ? 'Default.htm' : 'index.html'
  ip_address = n['ip_address']
  # When working with Vagrant, we need each node to report its IP address.
  if %w(hosted).include?(node['snippets']['virtualization'])
    ip_address = ::File.read("/vagrant/#{n['name']}-ipaddress.txt").strip
  end

  # For Vagrant/VirtualBox scenario, we need to vagrant up the cluster.
  ##################
  if node['snippets']['virtualization'] == 'virtualbox'
    with_snippet_options(platform: node_platform, lesson: 'set-up-your-chef-server', cwd: '~/learn-chef') do

      with_snippet_options(step: 'mkdir-chef-server') do

        snippet_execute "mkdir-chef-server-#{node_platform}" do
          command 'mkdir ~/learn-chef/chef-server'
          ignore_failure true
        end

        snippet_execute "cd-chef-server-#{node_platform}" do
          command 'cd ~/learn-chef/chef-server'
        end
      end

      with_snippet_options(step: 'vagrant-up-chef-server', cwd: '~/learn-chef/chef-server') do

        # This runs in multiple passes.
        # Destroy prior environment.
        # execute "vagrant-destroy-#{node_platform}" do
        #   cwd File.expand_path('~/learn-chef/chef-server')
        #   command 'vagrant destroy --force'
        #   ignore_failure true
        # end

        ntp_commands = {
          'ubuntu' => <<-EOH_UBUNTU.strip,
apt-get update
apt-get -y install ntp
service ntp stop
ntpdate -s time.nist.gov
service ntp start
EOH_UBUNTU
          'rhel' => <<-EOH_RHEL.strip
yum -y install ntp
systemctl start ntpd
systemctl enable ntpd
EOH_RHEL
        }
        boxes = {
          'ubuntu' => 'bento/ubuntu-14.04',
          'rhel' => 'bento/centos-7.2'
        }

        # Render template Vagrantfile.erb to /tmp.
        template '/tmp/Vagrantfile' do
          source 'Vagrantfile.erb'
          variables({
            :channel => node['products']['versions']['chef_server']['ubuntu'].split('-')[0],
            :version => node['products']['versions']['chef_server']['ubuntu'].split('-')[1],
            :ntp_commands => ntp_commands[node_platform],
            :box => boxes[node_platform],
            :hostname => n['name']
          })
        end

        # Write Vagrantfile.
        snippet_code_block "vagrantfile-#{node_platform}" do
          file_path '~/learn-chef/chef-server/Vagrantfile'
          content lazy { ::File.read('/tmp/Vagrantfile') }
        end

        # Vagrant up.
        snippet_execute "vagrant-up-#{node_platform}" do
          command 'vagrant up'
          # vagrant up produces a LOT of output.
          # don't write this output to file.
          write_stdout false
          write_stderr false
        end
      end

      ## 1. STEP

      # ensure directory is clean among passes
      directory "delete-dot-chef-#{node_platform}" do
        path ::File.expand_path('~/learn-chef/.chef')
        action :delete
        recursive false
      end

      with_snippet_options(step: 'mkdir-dot-chef') do

        snippet_execute 'mkdir-dot-chef' do
          command 'mkdir ~/learn-chef/.chef'
          ignore_failure true
        end
      end

      with_snippet_options(step: 'generate-knife-config') do

        # Get admin key.

        # TODO: Create node attribute for admin.pem.
        snippet_execute "copy-admin-key-#{node_platform}" do
          command 'cp ~/learn-chef/chef-server/secrets/admin.pem ~/learn-chef/.chef'
        end

        # Generate knife config.

        # TODO: Create node attribute for 4thcoffee.
        snippet_code_block "knife-rb-#{node_platform}" do
          file_path '~/learn-chef/.chef/knife.rb'
          content <<-'EOH'
# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
chef_server_url          "https://chef-server.test/organizations/4thcoffee"
cookbook_path            ["#{current_dir}/../cookbooks"]
EOH
        end

        snippet_execute "add-chef-server-to-hosts-file-#{node_platform}" do
          command 'echo "10.1.1.33 chef-server.test" | tee -a /etc/hosts'
        end

      end

      with_snippet_options(step: 'ls-dot-chef') do

        snippet_execute "ls-dot-chef-#{node_platform}" do
          command 'ls ~/learn-chef/.chef'
        end

      end

      with_snippet_options(step: 'validate-ssl-cert') do

        snippet_execute "knife-ssl-fetch-#{node_platform}" do
          command 'knife ssl fetch'
        end

        snippet_execute "knife-ssl-check-#{node_platform}" do
          command 'knife ssl check'
        end

      end
    end
  end

  # More setup
  ##################

  # Ensure Chef server doesn't have node.
  execute "ensure-knife-node-delete-#{node_name}" do
    command "knife node delete #{node_name} --yes --config ~/learn-chef/.chef/knife.rb"
    only_if "knife node list --config ~/learn-chef/.chef/knife.rb | grep #{node_name}"
  end
  execute "ensure-knife-client-delete-#{node_name}" do
    command "knife client delete #{node_name} --yes --config ~/learn-chef/.chef/knife.rb"
    only_if "knife client list --config ~/learn-chef/.chef/knife.rb | grep #{node_name}"
  end

  directory ::File.expand_path('~/.ssh')

  # Upload cookbook
  ##################

  # Ensure no versions of this cookbook are on the Chef server.
  execute "ensure-knife-cookbook-delete-#{cookbook}" do
    command "knife cookbook delete #{cookbook} --all --yes --config ~/learn-chef/.chef/knife.rb"
    only_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook}"
  end

  with_snippet_options(platform: node_platform, lesson: 'upload-a-cookbook', cwd: '~/learn-chef')

    # 1. Create cookbooks directory

    with_snippet_options(step: 'create-cookbooks-directory') do

      snippet_execute 'mkdir-cookbooks' do
        command 'mkdir ~/learn-chef/cookbooks'
        not_if 'stat ~/learn-chef/cookbooks'
      end

      snippet_execute 'cd-cookbooks' do
        command 'cd ~/learn-chef/cookbooks'
      end

  end

  # 2. Get cookbook from github

  with_snippet_options(step: 'git-clone-cookbook', cwd: '~/learn-chef/cookbooks') do

    snippet_execute "git-clone-#{cookbook}" do
      command "git clone https://github.com/learn-chef/#{cookbook}.git"
      not_if "stat ~/learn-chef/cookbooks/#{cookbook}"
    end

  end

  # Upload your cookbook to the Chef server

  with_snippet_options(step: 'upload-0-1-0') do

    snippet_execute "knife-cookbook-upload-#{cookbook}" do
      command "knife cookbook upload #{cookbook}"
      not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook}"
    end

    snippet_execute "knife-cookbook-list-#{cookbook}" do
      command 'knife cookbook list'
      #remove_lines_matching [/((?!#{cookbook}).)*]/] # ignore all other cookbooks
    end

  end

  # Bootstrap
  ##################

  with_snippet_options(platform: node_platform, lesson: 'bootstrap-your-node', cwd: '~/learn-chef') do

    with_snippet_options(step: 'bootstrap-your-node') do

      case node_platform
      when 'windows'
        node.run_state['bootstrap_command'][node_platform] = "knife bootstrap windows winrm #{ip_address} --winrm-user #{n['winrm_user']} --winrm-password '#{n['password']}' --node-name #{node_name} --run-list 'recipe[#{cookbook}]'"
      else # some sort of Linux
        case node['snippets']['virtualization']
        when 'aws-automate', 'aws-marketplace', 'azure-marketplace'
          node.run_state['bootstrap_command'][node_platform] = "knife bootstrap #{ip_address} --ssh-user #{n['ssh_user']} --sudo --identity-file #{n['identity_file']} --node-name #{node_name} --run-list 'recipe[#{cookbook}]'"
        when 'hosted'
          # Place private key
          file "#{node_name}-private-key"  do
            path ::File.expand_path(n['identity_file'])
            content ::File.read("/vagrant/.vagrant/machines/#{node_name}/vmware_fusion/private_key")
            mode '0600'
          end
          node.run_state['bootstrap_command'][node_platform] = "knife bootstrap #{ip_address} --ssh-user #{n['ssh_user']} --sudo --identity-file #{n['identity_file']} --node-name #{node_name} --run-list 'recipe[#{cookbook}]'"
        when 'virtualbox'
          snippet_execute "vagrant-ssh-config-#{node_name}" do
            cwd '~/learn-chef/chef-server'
            command "vagrant ssh-config #{node_name}"
          end
          # Run it again so we can process it more easily.
          ruby_block "vagrant-ssh-config-#{node_name}-1" do
            block do
              lines = `cd ~/learn-chef/chef-server && vagrant ssh-config #{node_name}`.split("\n")
              user = lines.grep(/\s*User\s+(.*)$/){$1}[0]
              port = lines.grep(/\s*Port\s+(.*)$/){$1}[0]
              identity_file = lines.grep(/\s*IdentityFile\s+(.*)$/){$1}[0]

              node.run_state['bootstrap_command'][node_platform] = "knife bootstrap localhost --ssh-port #{port} --ssh-user #{user} --sudo --identity-file #{identity_file} --node-name #{node_name} --run-list 'recipe[#{cookbook}]'"
            end
          end
        end
      end

      snippet_execute "bootstrap-#{node_name}" do
        command lazy { node.run_state['bootstrap_command'][node_platform] }
        remove_lines_matching [/locale/, /#########/, /Reading database/]
        not_if "knife node list --config ~/learn-chef/.chef/knife.rb | grep #{node_name}"
      end

      snippet_execute "knife-node-list-#{node_name}" do
        command "knife node list"
      end

      snippet_execute "knife-node-show-#{node_name}" do
        command "knife node show #{node_name}"
      end

      snippet_execute "curl-#{node_name}-1" do
        command "curl #{ip_address}"
      end
    end
  end

  # Update config
  ##################

  with_snippet_options(platform: node_platform, lesson: 'update-your-nodes-configuration') do

    with_snippet_options(cwd: '~/learn-chef', step: 'add-template-code-to-your-html') do

      # Update template.
      snippet_code_block "index-html-erb-#{node_name}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/templates/#{template_filename}.erb"
        source_filename "#{node_platform}/#{template_filename}.erb"
      end

      # Show current metadata.
      snippet_code_block "metadata-0-1-0-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
        content lazy {
          ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/metadata.rb"))
        }
      end

      # Update metadata.
      snippet_code_block "metadata-0-2-0-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
        content lazy { ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/metadata.rb")).sub("version '0.1.0'", "version '0.2.0'") }
      end

      # Upload your cookbook to the Chef server
      snippet_execute "upload-0-2-0-#{cookbook}" do
        command "knife cookbook upload #{cookbook}"
        not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook} | grep 0.2.0"
      end

      case node_platform
      when 'windows'
        node.run_state['knife_ssh_command'][node_platform] = "knife winrm #{ip_address} chef-client --manual-list --winrm-user #{n['winrm_user']} --winrm-password '#{n['password']}'"
      else
        case node['snippets']['virtualization']
        when 'hosted', 'aws-automate', 'aws-marketplace', 'azure-marketplace'
          node.run_state['knife_ssh_command'][node_platform]  = "knife ssh #{ip_address} 'sudo chef-client' --manual-list --ssh-user #{n['ssh_user']} --identity-file #{n['identity_file']}"
        when 'virtualbox'
          ruby_block "vagrant-ssh-config-#{node_name}-2" do
            block do
              lines = `cd ~/learn-chef/chef-server && vagrant ssh-config #{node_name}`.split("\n")
              user = lines.grep(/\s*User\s+(.*)$/){$1}[0]
              port = lines.grep(/\s*Port\s+(.*)$/){$1}[0]
              identity_file = lines.grep(/\s*IdentityFile\s+(.*)$/){$1}[0]

              node.run_state['knife_ssh_command'][node_platform] = "knife ssh localhost --ssh-port #{port} 'sudo chef-client' --manual-list --ssh-user #{user} --identity-file #{identity_file}"
            end
          end
        end
      end

      # knife ssh
      snippet_execute "knife-ccr-#{node_name}-1" do
        command lazy { node.run_state['knife_ssh_command'][node_platform] }
        remove_lines_matching [/locale/, /#########/]
      end

      # Confirm the result
      snippet_execute "curl-#{node_name}-2" do
        command "curl #{ip_address}"
      end
    end
  end

  # Resolve failure
  ##################

  with_snippet_options(platform: node_platform, lesson: 'resolve-a-failure') do

    with_snippet_options(cwd: '~/learn-chef', step: 'set-web-content-owner') do

      # Show current recipe.
      snippet_code_block "initial-default-recipe-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
        content lazy {
          ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"))
        }
      end

      # Update default recipe.
      snippet_code_block "add-web-user-err-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
        source_filename "#{platform}/add-web-user-err.rb"
      end

      # Update metadata.
      snippet_code_block "metadata-0-3-0-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
        content lazy { ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/metadata.rb")).sub("version '0.2.0'", "version '0.3.0'") }
      end

      # Upload your cookbook to the Chef server
      snippet_execute "upload-0-3-0-#{cookbook}" do
        command "knife cookbook upload #{cookbook}"
        not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook} | grep 0.3.0"
      end

      # knife ssh 'sudo chef-client' or
      # knife winrm 'chef-client'
      snippet_execute "knife-ccr-#{node_name}-2" do
        command lazy { node.run_state['knife_ssh_command'][node_platform] }
        ignore_failure true # in fact, we expect this to fail!
        remove_lines_matching [/locale/, /#########/]
      end

      #####

      # Update default recipe.
      snippet_code_block "add-web-user-fix-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/recipes/default.rb"
        source_filename "#{platform}/add-web-user-fix.rb"
      end

      # Update metadata.
      snippet_code_block "metadata-0-3-1-#{cookbook}" do
        file_path "~/learn-chef/cookbooks/#{cookbook}/metadata.rb"
        content lazy { ::File.read(::File.expand_path("~/learn-chef/cookbooks/#{cookbook}/metadata.rb")).sub("version '0.3.0'", "version '0.3.1'") }
      end

      # Upload your cookbook to the Chef server
      snippet_execute "upload-0-3-1-#{cookbook}" do
        command "knife cookbook upload #{cookbook}"
        not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook} | grep 0.3.1"
      end

      # knife ssh using key-based authentication
      snippet_execute "knife-ccr-#{node_name}-3" do
        command lazy { node.run_state['knife_ssh_command'][node_platform] }
        remove_lines_matching [/locale/, /#########/]
      end

      # Confirm the result
      snippet_execute "curl-#{node_name}-3" do
       command "curl #{ip_address}"
      end

    end

    with_snippet_options(step: 'cleaning-up', cwd: '~/learn-chef') do

      # Grab chef-client version from node before cleaning up.
      execute "get-node-chef-client-version-#{node_name}" do
        command "knife exec -E 'nodes.find(\"name:#{node_name}\") {|n| puts n.attributes.automatic.chef_packages.chef.version.strip }' --config ~/learn-chef/.chef/knife.rb > /tmp/#{node_name}-chef-client-version"
      end

      # Delete node & client

      snippet_execute "knife-node-delete-#{node_name}" do
        command "knife node delete #{node_name} --yes"
      end

      snippet_execute "knife-client-delete-#{node_name}" do
        command "knife client delete #{node_name} --yes"
      end

      # Delete cookbook

      snippet_execute "knife-cookbook-delete-#{cookbook}" do
        command "knife cookbook delete #{cookbook} --all --yes"
      end

      # Destroy VM

      if node['snippets']['virtualization'] == 'virtualbox'
        snippet_execute "vagrant-destroy-#{node_name}" do
          command 'vagrant destroy --force'
          cwd '~/learn-chef/chef-server'
        end
      end
    end
  end

  # Write config file.
  ##################

  platform_display_name = case node_platform
  when 'rhel'
    'CentOS 7.2'
  when 'ubuntu'
    'Ubuntu 14.04'
  when 'windows'
    "Windows Server 2012 R2"
  end
  snippet_config "manage-a-node-#{node_platform}" do
    tutorial 'manage-a-node'
    platform node_platform
    variables lazy {
      ({
        node_platform: node_platform,
        chef_client_version: ::File.read("tmp/#{n['name']}-chef-client-version").strip,
        node_display_name: platform_display_name
      })
    }
  end

end
