include LearnChef::SnippetHelpers
include LearnChef::ComplianceHelpers
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
property :excerpt_stdout, [ Array, Hash, nil ], default: nil
property :prompt_character, [ String, nil ], default: nil
property :left_justify, [ TrueClass, FalseClass ], default: false
property :write_stdout, [ TrueClass, FalseClass ], default: true
property :write_stderr, [ TrueClass, FalseClass ], default: true
property :write_exitstatus, [ TrueClass, FalseClass ], default: false

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
    language: shell == 'powershell' ? 'ps' : shell, #TODO
    display_path: cwd
  }

  # Run the command.
  options = {}
  options[:timeout] = 7200
  options[:cwd] = ::File.expand_path(cwd)
  env = node['workstation']['environment'][node['platform']]
  options[:environment] = { "PATH" => env } if env

  if shell == 'powershell'
    result = powershell_out(translate_command, options)
  else
    result = shell_out(translate_command, options)
  end
  result.error! unless ignore_failure

  # Clean the output.
  clean_stdout = clean_output(result.stdout.dup)
  clean_stderr = clean_output(result.stderr.dup)
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
  stdout = remove_lines(stdout, [remove_lines_matching].flatten) if remove_lines_matching
  stderr = trim_output(clean_stderr, trim_stderr)
  stdout = excerpt_output(stdout, excerpt_stdout) if excerpt_stdout

  if left_justify
    stdout.unindent!
    stderr.unindent!
  end

  # Write stdout.
  if write_stdout
    file ::File.join(snippet_full_path, 'stdout') do
      content stdout
    end
  end

  if write_stderr
    # Write stderr.
    file ::File.join(snippet_full_path, 'stderr') do
      content stderr
    end
  end

  # Write exitstatus.
  if write_exitstatus
    file ::File.join(snippet_full_path, 'exitstatus') do
      content "#{prompt_character} echo $?\n#{result.exitstatus.to_s}\n"
    end
  end
end

def trim_output(output, regions)
  if regions
    [regions].flatten.each do |region|
      match_string = /(#{region[:from]}).*#{region[:lazy] || true ? '?' : ''}(#{region[:to]})/m
      output.gsub!(match_string, "\1#{region[:replace_with] || "[TRIMMED_OUTPUT]"}\2")
    end
  end
  output
end

def excerpt_output(output, excerpts)
  lines = output.lines
  [excerpts].flatten.each do |excerpt|
    start = -1
    lines.each_with_index do |line, index|
      start = index if start == -1 && line =~ excerpt[:from]
      return lines[start..index].join("\n") if start != -1 && line =~ excerpt[:to]
    end
  end
  output
end

def remove_lines(content, matchers)
  output = []
  content.lines.each do |line|
    output << line unless matchers.any? { |matcher| line =~ matcher }
  end
  output.join("\n")
end

# Performs necessary translation some commands require.
def translate_command
  platform = node['platform']
  if platform == 'windows' && command =~ /cd\s+~/
    # Windows doesn't seem to like running `cd ~/path`. Expand the path fully.
    m = command.match /cd\s+(~.+)/
    "cd #{::File.expand_path(m[1])}"
  elsif command =~ /^inspec/
    # inspec doesn't seem to work until reboot
    "/opt/chefdk/embedded/bin/" + command
  elsif command == 'chef verify'
    if platform == 'windows'
      'chef verify'
    else
      # https://github.com/chef/chef-dk/issues/928
      'TERM=xterm-256color chef verify'
    end
  elsif command =~ /^chef-client/ || command =~ /^sudo chef-client/
    translate_chef_client_command
  elsif command =~ /knife/
    # Not sure why, but from shell_out, knife.rb isn't found unless you specify the config file path.
    command + " --config ~/learn-chef/.chef/knife.rb --no-color"
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
# Examples:
#   [32m- create new directory cookbooks/learn_chef_httpd/templates/default[0m
#   [31;1m  ✖  xccdf_org.cisecurity.benchmarks_rule_6.2.1_Set_SSH_Protocol_to_2:
# become:
#   - create new directory cookbooks/learn_chef_httpd/templates/default
#     ✖  xccdf_org.cisecurity.benchmarks_rule_6.2.1_Set_SSH_Protocol_to_2:
def clean_output(output)
  cleaned_output = []
  output.lines.each do |line|
    clean_line = line.gsub(/\[[\d+;?]+m/, '').gsub(/^(.*)\[\d+m/, '\1')
    unwanted = [/setlocale/, /\[K/]
    cleaned_output << clean_line unless unwanted.any? { |s| clean_line =~ s }
  end
  cleaned_output.join("\n")
  # if command =~ /^chef\s/ || command =~ /^knife\s/
  #   output.gsub(/\[\d+m/, '').gsub(/^(.*)\[\d+m/, '\1')
  # elsif command =~ /^vagrant\s/
  #   output.gsub(/\[K/, '') # clear out K markers
  # else
  #   output
  # end
end
