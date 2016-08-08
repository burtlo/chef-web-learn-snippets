default['snippets']['virtualization'] = 'vagrant'
default['snippets']['root_directory'] = ::File.join('/', node.default['snippets']['virtualization'], 'snippets')
default['snippets']['prompt_character'] = '$'
