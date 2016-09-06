#
# Cookbook Name:: manage_a_node
# Recipe:: setup-node
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory ::File.expand_path('~/.aws')
directory ::File.expand_path('~/.ssh')

# Copy credentials.
file ::File.expand_path('~/.aws/credentials')  do
  content ::File.open("/vagrant/secrets/credentials").read
end
file ::File.expand_path('~/.aws/config')  do
  content ::File.open("/vagrant/secrets/config").read
end
file ::File.expand_path('~/.ssh/private_key')  do
  content ::File.open("/vagrant/secrets/private_key").read
  mode '0600'
end

ruby_block 'set-aws-envvars' do
  block do
    s = ::File.open("/vagrant/secrets/credentials").read
    ENV["AWS_ACCESS_KEY_ID"] = s.match(/^aws_access_key_id=(.*)$/)[1]
    ENV["AWS_SECRET_ACCESS_KEY"] = s.match(/^aws_secret_access_key=(.*)$/)[1]
  end
end

file 'delete-aws-credentials'  do
  path ::File.expand_path('~/.aws/credentials')
  action :delete
end
file 'delete-aws-config' do
  path ::File.expand_path('~/.aws/config')
  action :delete
end

with_driver 'aws:default' do
  machine 'node1' do
    machine_options bootstrap_options: {
      image_id: 'ami-6d1c2007',
      availability_zone: 'us-east-1b',
      instance_type: 't2.micro',
      security_group_ids: 'sg-0e08cf75',
      associate_public_ip_address: true,
      key_name: 'tpetchel-mktg',
      key_path: "~/.ssh/private_key",
    }
    converge false
    action :ready
    #tag 'manage-a-node-centos-node1'
  end
end
