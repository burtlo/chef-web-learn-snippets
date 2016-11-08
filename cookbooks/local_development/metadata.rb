name 'local_development'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures local_development'
long_description 'Installs/Configures local_development'
version '0.1.0'

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Issues` link
# issues_url 'https://github.com/<insert_org_here>/local_development/issues' if respond_to?(:issues_url)

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Source` link
# source_url 'https://github.com/<insert_org_here>/local_development' if respond_to?(:source_url)

depends 'manage_a_node'
depends 'snippet'
depends 'workstation'
depends 'git', '~> 4.6.0'
