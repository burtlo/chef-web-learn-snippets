namespace :cookbook do
  desc 'Vendor cookbooks for a scanario'
  task :vendor, :scenario do |_t, args|
    scenario = args[:scenario]
    # Vendor cookbooks from:
    # cookbooks/#{scenario}
    # to:
    # scenarios/#{scenario}/vendored-cookbooks
    source_cookbook_path = "cookbooks/#{scenario}"
    sh "rm -rf scenarios/#{scenario}/vendored-cookbooks"
    sh "rm -rf #{source_cookbook_path}/Berksfile.lock"
    sh "berks vendor -b #{source_cookbook_path}/Berksfile scenarios/#{scenario}/vendored-cookbooks"
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
      puts "$ export SNIPPET_DIRECTORY=~/Development/cia/chef-web-learn/snippets"
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
end

namespace :scenario do
  desc 'Lists all scenarios'
  task :list do |_t, args|
    find_scenarios.each do |s|
      puts s
    end
  end

  desc 'Runs a scanario from start to end'
  task :run, :scenario do |_t, args|
    scenario = args[:scenario]
    tasks = %w[scenario:start vagrant:destroy]
    tasks.each do |task|
      Rake::Task[task].invoke(scenario)
      Rake::Task[task].reenable
    end
  end

  # Run this task to start a scenario that you're working on.
  desc 'Starts a scanario'
  task :start, :scenario do |_t, args|
    scenario = args[:scenario]
    tasks = %w[vagrant:destroy snippets:delete cookbook:vendor vagrant:up vagrant:provision]
    tasks.each do |task|
      Rake::Task[task].invoke(scenario)
      Rake::Task[task].reenable
    end
  end

  # Run this task as you develop scenarios.
  desc 'Resumes an active scanario'
  task :resume, :scenario do |_t, args|
    scenario = args[:scenario]
    # Vendor in updated cookbooks and reprovision.
    tasks = %w[cookbook:vendor vagrant:provision]
    tasks.each do |task|
      Rake::Task[task].invoke(scenario)
      Rake::Task[task].reenable
    end
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
      puts (exists ? "[X]".pink : "[C]".green) + indent + (level == 0 ? target : File.basename(target)) + "/"
      files_copied += copy_files(path, target, level + 1)
    else
      exists = File.exist?(target)
      identical = exists && FileUtils.identical?(path, target)
      unless identical
        FileUtils.copy(path, target)
        files_copied += 1
      end
      puts (identical ? "[X]".pink : exists ? "[U]".yellow : "[C]".green) + indent + x
    end
  end
  files_copied
end

def find_scenarios
  scenarios = []
  Dir.foreach('scenarios') do |x|
    path = File.join('scenarios', x)
    if x == "." or x == ".."
      next
    elsif File.directory?(path)
      scenarios.push x
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
