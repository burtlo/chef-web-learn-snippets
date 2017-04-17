name 'create_a_web_app'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures create_a_web_app'
long_description 'Installs/Configures create_a_web_app'
version '0.1.0'

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Issues` link
# issues_url 'https://github.com/<insert_org_here>/create_a_web_app/issues' if respond_to?(:issues_url)

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Source` link
# source_url 'https://github.com/<insert_org_here>/create_a_web_app' if respond_to?(:source_url)

depends 'manage_a_node'
depends 'snippet'
depends 'workstation'
depends 'git', '~> 4.6.0'
