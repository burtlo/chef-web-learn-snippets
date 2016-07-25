include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

property :id, String, required: true, name_property: true
property :command, String, required: true
property :shell, String, default: 'bash'
property :snippet_path, [ String, nil ], default: nil
property :snippet_file, [ String, nil ], default: nil
property :cwd, [ String, nil ], default: nil
property :trim_stdout, [ Array, Hash, nil ], default: nil
property :trim_stderr, [ Array, Hash, nil ], default: nil
property :abort_on_failure, [ TrueClass, FalseClass ], default: false

def initialize(*args)
  super
  @snippet_path ||= snippet_options[:snippet_path]
  @snippet_file ||= snippet_options[:snippet_file]
  @cwd = @cwd || snippet_options[:cwd] || '~'
end

action :run do
  # Run the command.
  result = shell_out(command_for_shell(translate_command), cwd: ::File.expand_path(cwd))
  result.error! if abort_on_failure

  # Clean the output.
  clean_stdout = clean_output(result.stdout)

  # This is the file that holds the manifest.
  manifest_filename = ::File.join(snippet_path, snippet_file) + '.yml'

  # Generate a base filename to store stdout and stderr.
  base_outstr_filename = make_base_filename(snippet_file + id)

  # Ensure snippet directory exists.
  directory snippet_path do
    recursive true
  end

  # Update the manifest.
  new_item = {
    id: id,
    snippet_tag: "<% command_snippet('#{snippet_file}', '#{id}') %>",
    language: shell,
    path: cwd,
    exit_code: result.exitstatus,
    output_base: base_outstr_filename
  }
  manifest = update_manifest(load_manifest(manifest_filename), new_item)

  # Write manifest.
  file manifest_filename do
    content manifest
  end

  # Write raw output (helpful for debugging, not copied over).

  # Write stdin.
  file ::File.join(snippet_path, stdin_file(base_outstr_filename)) + '.raw' do
    content translate_command + "\n"
  end

  # Write stdout.
  file ::File.join(snippet_path, stdout_file(base_outstr_filename)) + '.raw' do
    content result.stdout
  end

  # Write stderr.
  file ::File.join(snippet_path, stderr_file(base_outstr_filename)) + '.raw' do
    content result.stderr
  end

  # Write cleaned snippet output.

  # Write stdin.
  file ::File.join(snippet_path, stdin_file(base_outstr_filename)) do
    content '$ ' + command + "\n"
  end

  # Transform output streams.
  stdout = trim_output(clean_stdout, trim_stdout)
  stderr = trim_output(result.stderr, trim_stderr)

  # Write stdout.
  file ::File.join(snippet_path, stdout_file(base_outstr_filename)) do
    content stdout
  end

  # Write stderr.
  file ::File.join(snippet_path, stderr_file(base_outstr_filename)) do
    content stderr
  end
end

# Generates a stdin filename.
def stdin_file(base)
  base + ".stdin"
end

# Generates a stdout filename.
def stdout_file(base)
  base + ".stdout"
end

# Generates a stderr filename.
def stderr_file(base)
  base + ".stderr"
end

# Generates the final command to run in the current shell.
def command_for_shell(cmd)
  case shell
  when 'bash'
    cmd
  when 'ps', 'powershell'
    "powershell.exe -Command \"#{cmd}\""
  end
end

def trim_output(output, regions)
  if regions
    [regions].flatten.each do |region|
      match_string = /(#{region[:from]}).*?(#{region[:to]})/m
      output.gsub!(match_string, "\1#{region[:replace_with] || "[TRIMMED_OUTPUT]"}\2")
    end
  end
  output
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
  else
    output
  end
end
