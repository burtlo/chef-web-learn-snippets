require 'yaml'

namespace :cookbook do
  desc 'Vendor cookbooks for a scanario'
  task :vendor, :scenario do |_t, args|
    scenario = args[:scenario]
    # Vendor cookbooks from:
    # cookbooks/#{cookbook} <= load cookbook from config file
    # to:
    # scenarios/#{scenario}/vendored-cookbooks
    sh "rm -rf scenarios/#{scenario}/vendored-cookbooks"
    config = YAML.load_file("scenarios/#{scenario}/config.yml")
    config[:cookbooks].each do |cookbook|
      source_cookbook_path = "cookbooks/#{cookbook}"
      sh "rm -rf #{source_cookbook_path}/Berksfile.lock"
      sh "berks vendor -b #{source_cookbook_path}/Berksfile scenarios/#{scenario}/vendored-cookbooks"
    end
  end
end

namespace :snippets do
  desc 'Delete snippets directory for a scenario'
  task :delete, :scenario do |_t, args|
    sh "rm -rf scenarios/#{args[:scenario]}/snippets"
  end

  desc 'Copies snippets from a scenario to another directory'
  task :copy, :scenario, :destination do |_t, args|
    if ENV['SNIPPET_DIRECTORY']
      from = "scenarios/#{args[:scenario]}/snippets"
      to = ENV['SNIPPET_DIRECTORY']
      puts "Copying snippets from #{from} to #{to}..."
      puts "#{copy_files(from, to)} files copied."
    else
      puts "Set the SNIPPET_DIRECTORY environment variable to the root of your snippets directory. Example:"
      puts "$".green + " export SNIPPET_DIRECTORY=~/Development/cia/chef-web-learn/snippets"
    end
  end

  desc 'Copies snippets locally from the running Vagrant box'
  task :rsync, :scenario, :method, :private_key_file do |t, args|
    method = args[:method] || 'ssh'
    private_key_file = args[:private_key_file] || 'id_rsa'
    case method
    when 'ssh'
      download_files_ssh(args[:scenario], private_key_file)
    when 'ftp'
      download_files_ftp(args[:scenario])
    else
      raise "Unknown transfer method '#{method}'"
    end
  end
end

namespace :vagrant do
  desc 'vagrant up machines for a scanario'
  task :up, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant up"
  end

  desc 'vagrant destroy machines for a scanario'
  task :destroy, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant destroy --force"
  end

  desc 'vagrant provision a scanario'
  task :provision, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant provision"
  end

  desc 'vagrant reload a scanario'
  task :reload, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant reload"
  end

  desc 'vagrant halt a scanario'
  task :halt, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant halt"
  end

  desc 'vagrant status a scanario'
  task :status, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant status"
  end

  desc 'upgrade vagrant boxes for scenario'
  task :upgrade, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} vagrant destroy && vagrant up --no-provision && vagrant box update"
  end

  desc 'vagrant ssh into a box'
  task :ssh, :scenario, :vm do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && vagrant ssh #{args[:vm]}"
  end
end

namespace :tf do
  desc 'terraform apply machines for a scanario'
  task :apply, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && ~/terraform apply -var-file=terraform.tfvars"
  end

  desc 'terraform destroy machines for a scanario'
  task :destroy, :scenario do |_t, args|
    sh "cd scenarios/#{args[:scenario]} && ~/terraform destroy --force"
  end
end

namespace :scenario do
  desc 'Lists all scenarios'
  task :list do |_t, args|
    find_scenarios.each do |s|
      puts s[:scenario].pink
      s[:platforms].each do |p|
        puts "  " + p[:platform].yellow
        p[:virtualizations].each do |v|
          puts "    " + v.green
        end
      end
    end
  end

  desc 'Runs a scanario from start to end'
  task :run, :scenario do |_t, args|
    scenario = args[:scenario]
    tasks = %w[scenario:start scenario:cleanup]
    tasks.each do |task|
      Rake::Task[task].invoke(scenario)
      Rake::Task[task].reenable
    end
  end

  # Run this task to start a scenario that you're working on.
  desc 'Starts a scanario'
  task :start, :scenario do |_t, args|
    scenario = args[:scenario]
    ns = scenario_namespace(scenario)
    tasks = []
    tasks << "#{ns}:destroy"
    tasks << "snippets:delete"
    tasks << "cookbook:vendor"
    tasks << (ns == 'vagrant' ? "vagrant:up" : "tf:apply")
    tasks.each do |task|
      Rake::Task[task].invoke(scenario)
      Rake::Task[task].reenable
    end
  end

  # Run this task as you develop scenarios.
  desc 'Resumes an active scanario'
  task :resume, :scenario do |_t, args|
    scenario = args[:scenario]
    # Vendor in updated cookbooks, reload, and reprovision.
    ns = scenario_namespace(scenario)
    tasks = []
    tasks << "cookbook:vendor"
    if (ns == 'vagrant')
      tasks << "vagrant:reload"
      tasks << "vagrant:provision"
    else
      tasks << "tf:apply"
    end
    tasks.each do |task|
      Rake::Task[task].invoke(scenario)
      Rake::Task[task].reenable
    end
  end

  # Run this task to cleanup a scenario
  desc 'Cleans up an active scanario'
  task :cleanup, :scenario do |_t, args|
    scenario = args[:scenario]
    task = "#{scenario_namespace(scenario)}:destroy"
    Rake::Task[task].invoke(scenario)
    Rake::Task[task].reenable
  end
end

def copy_files(from, to, level = 0)
  files_copied = 0
  Dir.foreach(from) do |x|
    path = File.join(from, x)
    target = File.join(to, x)
    indent = "  " * level
    if x == "." or x == ".."
      next
    elsif File.directory?(path)
      exists = Dir.exist?(target)
      Dir.mkdir(target) unless exists
      puts (exists ? "[I]".pink : "[C]".green) + indent + (level == 0 ? target : File.basename(target)) + "/"
      files_copied += copy_files(path, target, level + 1)
    else
      next if x.end_with?('.raw') # skip these files
      exists = File.exist?(target)
      # Check if file has zero length.
      if File.size(path) == 0
        if exists
          # Delete file from target - we're replacing it with one with zero length.
          FileUtils.rm(target)
          puts "[D]".red + indent + x
        else
          # Skip the file.
          puts "[0]".red + indent + x
        end
        next
      end

      identical = exists && FileUtils.identical?(path, target)
      unless identical
        FileUtils.copy(path, target)
        files_copied += 1
      end
      puts (identical ? "[I]".pink : exists ? "[U]".yellow : "[C]".green) + indent + x
    end
  end
  files_copied
end

def find_virtualizations(platform_path)
  virtualizations = []
  Dir.foreach(platform_path) do |x|
    path = File.join(platform_path, x)
    if x.start_with? "."
      next
    elsif File.directory?(path)
      virtualizations.push x
    end
  end
  virtualizations
end

def find_platforms(scenario_path)
  platforms = []
  Dir.foreach(scenario_path) do |x|
    path = File.join(scenario_path, x)
    if x.start_with? "."
      next
    elsif File.directory?(path)
      platforms.push ({
        platform: x,
        virtualizations: find_virtualizations(path)
      })
    end
  end
  platforms
end

def find_scenarios
  scenarios = []
  Dir.foreach('scenarios') do |x|
    path = File.join('scenarios', x)
    if x.start_with? "."
      next
    elsif File.directory?(path)
      scenarios.push ({
        scenario: x,
        platforms: find_platforms(path)
      })
    end
  end
  scenarios
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
  def red
    colorize(31)
  end
  def green
    colorize(32)
  end
  def yellow
    colorize(33)
  end
  def pink
    colorize(35)
  end
end

def file_downloader(scenario, ip_address, username, key, from_there, to_here, options = {})
  # TODO: This fails on GCE.
  puts "If this command fails, try running:".red
  puts "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r -i #{key} #{username}@#{ip_address}:#{from_there} #{to_here}\n\n"

  require 'net/scp'
  Net::SCP::download!(ip_address, username, from_there, to_here, :ssh => { :keys => key, :verbose => :debug}, :paranoid => true, **options)
end

def download_files_ssh(scenario, private_key_file)
  if vagrant_scenario?(scenario)
    ssh_config = `cd scenarios/#{scenario} && vagrant ssh-config`.split("\n")
    ip_address = ssh_config.grep(/^\s+HostName (.+)$/) { $1 }[0]
    username = ssh_config.grep(/^\s+User (.+)$/) { $1 }[0]
    key = ssh_config.grep(/^\s+IdentityFile (.+)$/) { $1 }[0]
    from_there = "/vagrant/snippets"
    to_here = "scenarios/#{scenario}"
    file_downloader scenario, ip_address, username, key, from_there, to_here, :recursive => true
  elsif terraform_scenario?(scenario)
    ssh_config = `cd scenarios/#{scenario} && ~/terraform show`.split("\n")
    ip_address = ssh_config.grep(/^\s*ip_address\s+=\s+(.+)$/) { $1 }[0]
    username = ssh_config.grep(/admin_username = (.+)$/) { $1 }[0]
    key = File.expand_path("~/.ssh/#{private_key_file}")
    from_there = "/vagrant/snippets"
    to_here = "scenarios/#{scenario}"
    file_downloader scenario, ip_address, username, key, from_there, to_here, :recursive => true
  else
    raise 'No Vagrantfile or Terraform plan found!'
  end
end

def download_files_ftp_aux(ftp, local_path)
  files = ftp.nlst
  files.each do |f|
    begin
      if ftp.size(f).is_a? Numeric
        ftp.gettextfile(f, File.join(local_path, f))
      end
    rescue Net::FTPPermError
      pwd = ftp.pwd
      ftp.chdir(f)
      new_path = File.join(local_path, f)
      Dir.mkdir(new_path) unless Dir.exist?(new_path)
      download_files_ftp_aux(ftp, new_path)
      ftp.chdir(pwd)
    end
  end
end

def download_files_ftp(scenario)
  ssh_config = `cd scenarios/#{scenario} && ~/terraform show`.split("\n")
  public_dns = ssh_config.grep(/^\s*public_dns\s+=\s+(.+)$/) { $1 }[0] ||
               ssh_config.grep(/^\s*ip_address\s+=\s+(.+)$/) { $1 }[0]
  puts "Public DNS is: " + public_dns
  username = 'chef'
  password = 'P4ssw0rd!'
  to_here = "scenarios/#{scenario}"
  require 'net/ftp'
  ftp = Net::FTP.new(public_dns, username, password)
  download_files_ftp_aux(ftp, File.expand_path("scenarios/#{scenario}"))
  ftp.close
end

def vagrant_scenario?(scenario)
  File.exists?("scenarios/#{scenario}/Vagrantfile")
end

def terraform_scenario?(scenario)
  File.exists?("scenarios/#{scenario}/main.tf")
end

def scenario_namespace(scenario)
  if vagrant_scenario?(scenario)
    'vagrant'
  elsif terraform_scenario?(scenario)
    'tf'
  else
    raise 'No Vagrantfile or Terraform plan found!'
  end
end
