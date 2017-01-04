#
# Cookbook Name:: hab_getting_started
# Recipe:: prerequisites_linux
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'git'

with_snippet_options(lesson: 'prerequisites')

with_snippet_options(cwd: '~', step: 'install-habitat') do

  snippet_execute 'download-package' do
    command 'wget "https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux" -O hab-latest.tar.gz'
    not_if 'stat ~/hab-latest.tar.gz'
    notifies :run, 'snippet_execute[untar-package]', :immediately
  end

  snippet_execute 'untar-package' do
    command 'tar -xvf hab-latest.tar.gz'
    action :nothing
  end

end
