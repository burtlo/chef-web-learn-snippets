package 'httpd'

service 'httpd' do
  action [:enable, :start]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
  mode '0644'
  owner 'web_admin'
  group 'web_admin'
end
