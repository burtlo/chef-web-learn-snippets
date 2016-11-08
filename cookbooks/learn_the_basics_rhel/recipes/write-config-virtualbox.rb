if node['platform'] == 'windows'
  #vagrant_windows_version = 'C:/vagrant/vagrant-windows.version'
  #vagrant_ubuntu_version = 'C:/vagrant/vagrant-ubuntu.version'
  #virtualbox_windows_version = 'C:/vagrant/virtualbox-windows.version'
  #virtualbox_ubuntu_version = 'C:/vagrant/virtualbox-ubuntu.version'
else
  #vagrant_windows_version = '/vagrant/vagrant-windows.version'
  vagrant_ubuntu_version = '/vagrant/vagrant-ubuntu.version'
  #virtualbox_windows_version = '/vagrant/virtualbox-windows.version'
  virtualbox_ubuntu_version = '/vagrant/virtualbox-ubuntu.version'
end

snippet_config 'learn-the-basics' do
  variables lazy {
    ({
      #:vagrant_windows_version => ::File.read(vagrant_windows_version),
      :vagrant_ubuntu_version => ::File.read(vagrant_ubuntu_version),
      #:virtualbox_windows_version => ::File.read(virtualbox_windows_version),
      :virtualbox_ubuntu_version => ::File.read(virtualbox_ubuntu_version)
    })
  }
end
