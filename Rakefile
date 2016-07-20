# require 'erb'
# require 'json'
# require 'openssl'
# require 'net/ssh'
# require 'yaml'

namespace :cookbook do
  desc 'Vendor cookbooks for a scanario'
  task :vendor, :scenario do |_t, args|
    scenario = args[:scenario]
    # Vendor cookbooks from:
    # cookbooks/#{scenario}
    # to:
    # scenarios/#{scenario}/vendored-cookbooks.
    source_cookbook_path = "cookbooks/#{scenario}"
    sh "rm -rf scenarios/#{scenario}/vendored-cookbooks"
    sh "rm -rf #{source_cookbook_path}/Berksfile.lock"
    sh "berks vendor -b #{source_cookbook_path}/Berksfile scenarios/#{scenario}/vendored-cookbooks"
  end
end
