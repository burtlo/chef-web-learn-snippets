include Chef::Mixin::ShellOut

property :file_path, String, required: true, name_property: true
property :source_template, [ String, nil ], required: true
property :cookbook_path, [ String, nil ], required: true

def initialize(*args)
  super
end

action :up do
  template ::File.join(file_path, 'Vagrantfile') do
    source source_template
    variables({
      :cookbook_path => cookbook_path
    })
  end

  execute "vagrant up #{file_path}" do
    command 'vagrant up'
    cwd ::File.expand_path(file_path)
  end
end
