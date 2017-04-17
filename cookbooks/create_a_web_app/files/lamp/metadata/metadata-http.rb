name 'lamp'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures lamp'
long_description 'Installs/Configures lamp'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/learn-chef/lamp/issues' if respond_to?(:issues_url)
source_url 'https://github.com/learn-chef/lamp' if respond_to?(:source_url)
supports 'ubuntu'

depends 'httpd', '~> 0.4'
