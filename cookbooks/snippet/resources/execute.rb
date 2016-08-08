include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

property :id, String, required: true, name_property: true
property :tutorial, [ String, nil ], default: nil
property :platform, [ String, nil ], default: nil
property :virtualization, [ String, nil ], default: nil
property :lesson, [ String, nil ], default: nil
property :step, [ String, nil ], default: nil
property :workstation_platform, [ String, nil ], default: nil
property :command, String, required: true
property :shell, [ String, nil ], default: nil
property :cwd, [ String, nil ], default: nil
property :trim_stdout, [ Array, Hash, nil ], default: nil
property :remove_lines_matching, [ Array, String, Regexp, nil ], default: nil
property :trim_stderr, [ Array, Hash, nil ], default: nil
property :abort_on_failure, [ TrueClass, FalseClass ], default: true
property :prompt_character, [ String, nil ], default: nil

def initialize(*args)
  super
  @tutorial ||= snippet_options[:tutorial]
  @platform ||= snippet_options[:platform]
  @virtualization ||= snippet_options[:virtualization]
  @lesson ||= snippet_options[:lesson]
  @step ||= snippet_options[:step]
  @cwd ||= (snippet_options[:cwd] || '~')
  @prompt_character ||= (snippet_options[:prompt_character] || '$')
  @workstation_platform ||= (snippet_options[:workstation_platform] || node['platform'])
  @shell ||= (snippet_options[:shell] || 'bash')
end

action :run do
  # Where we place snippet files.
  snippet_partial_path = ::File.join(tutorial, platform, virtualization, lesson, step, id + "-#{workstation_platform}")
  snippet_full_path = ::File.join(snippets_root_dir, snippet_partial_path)
  snippet_metadata_filename = ::File.join(snippet_full_path, 'metadata.yml')

  # Metadata about the snippet.
  metadata = {
    snippet_tag: "<% command_snippet(page: current_page, path: '#{::File.join(step, id)}') %>",
    language: shell,
    display_path: cwd
  }

  # Run the command.
  options = {}
  options[:cwd] = ::File.expand_path(cwd)
  #env = env_for_platform
  # if node['platform'] == 'windows'
  #   options[:env] = {
  #     "PATH" => powershell_out("[System.Environment]::GetEnvironmentVariable('PATH','Machine')").stdout
  #   }
  # end
  #options[:env] = env if env
  if shell == 'powershell'
    result = powershell_out(translate_command, options)
  else
    result = shell_out(translate_command, options)
  end
  result.error! if abort_on_failure

  # Clean the output.
  clean_stdout = clean_output(result.stdout.dup)

  # Write metadata.
  directory ::File.dirname(snippet_metadata_filename) do
    recursive true
  end
  file snippet_metadata_filename do
    content metadata.to_yaml(line_width: -1)
  end

  # Write raw output (helpful for debugging, not copied over).

  # Write stdin.
  file ::File.join(snippet_full_path, 'stdin.raw') do
    content translate_command + "\n"
  end

  # Write stdout.
  file ::File.join(snippet_full_path, 'stdout.raw') do
    content result.stdout
  end

  # Write stderr.
  file ::File.join(snippet_full_path, 'stderr.raw') do
    content result.stderr
  end

  # Write exitstatus.
  file ::File.join(snippet_full_path, 'exitstatus.raw') do
    content result.exitstatus.to_s
  end

  # Write cleaned snippet output.

  # Write stdin.
  file ::File.join(snippet_full_path, 'stdin') do
    content "#{prompt_character} " + command + "\n"
  end

  # Transform output streams.
  stdout = trim_output(clean_stdout, trim_stdout)
  stdout = remove_lines(stdout, remove_lines_matching) if remove_lines_matching
  stderr = trim_output(result.stderr, trim_stderr)

  # Write stdout.
  file ::File.join(snippet_full_path, 'stdout') do
    content stdout
  end

  # Write stderr.
  file ::File.join(snippet_full_path, 'stderr') do
    content stderr
  end
end

# # Generates the final command to run in the current shell.
# def command_for_shell(cmd)
#   case shell
#   when 'bash'
#     cmd
#   when 'powershell'
#     cmd
#   when 'ps', 'powershell'
#     require 'securerandom'
#     ::Dir.mkdir("C:\\vagrant\\scripts") unless ::Dir.exist?("C:\\vagrant\\scripts")
#     filename = "C:\\vagrant\\scripts\\#{SecureRandom.hex[0..7]}.ps1"
#     ::File.write(filename, <<-EOH
# Push-Location "#{::File.expand_path(cwd)}"
# [Environment]::CurrentDirectory = $PWD
# $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
# #{cmd}
# Pop-Location
# [Environment]::CurrentDirectory = $PWD
# EOH
# )
#     #"powershell.exe -executionpolicy Bypass -command \"& #{filename}\""
#     filename
#   end
# end

def trim_output(output, regions)
  if regions
    [regions].flatten.each do |region|
      match_string = /(#{region[:from]}).*#{region[:lazy] || true ? '?' : ''}(#{region[:to]})/m
      output.gsub!(match_string, "\1#{region[:replace_with] || "[TRIMMED_OUTPUT]"}\2")
    end
  end
  output
end

def remove_lines(s, match)
  s.gsub(match, "")
end

# Performs necessary translation some commands require.
def translate_command
  if command =~ /chef-client/
    translate_chef_client_command
  else
    command
  end
end

# HACK: Works around these issues:
# https://github.com/chef/chef/issues/2514
# https://tickets.opscode.com/browse/CHEF-4874
# We also need to throw in --no-color to remove color markers.
def translate_chef_client_command
  tokens = command.split(' ')
  if tokens.last =~ /\./ # implies `chef-client ... recipe.rb`
    recipe_file = tokens.pop # filename needs to be shifted to end
  else
    recipe_file = ''
  end
  (tokens.join(' ') + ' --no-color --log_level warn --force-formatter ' + recipe_file).rstrip
end

# Commands such as `chef` colorize output and don't provide a way to suppress colorization.
# Example:
#   [32m- create new directory cookbooks/learn_chef_httpd/templates/default[0m
# becomes:
#   - create new directory cookbooks/learn_chef_httpd/templates/default
def clean_output(output)
  if command =~ /^chef\s/
    output.gsub(/\[\d+m$/, '').gsub(/^(.*)\[\d+m/, '\1')
  elsif command =~ /^vagrant\s/
    output.gsub(/\[K/, '') # clear out K markers
  else
    output
  end
end

# def env_for_platform
#   case node['platform']
#   when 'windows'
#     nil
#   else
#     nil
#   end
# end

# def default_shell_for_platform
#   case node['platform']
#   when 'windows'
#     'powershell'
#   else
#     'bash'
#   end
# end
