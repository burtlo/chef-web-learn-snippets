default['product']['versions'].tap do |pkg|
  pkg['chef'] = 'stable-12.11.18'
  pkg['chefdk'] = 'stable-0.15.15'
  pkg['chef-server'] = 'stable-12.6.0'
  pkg['delivery'] = 'stable-0.4.437'
  pkg['compliance'] = 'stable-1.3.1'
end

default['snippets']['root_directory'] = '/vagrant/snippets'
