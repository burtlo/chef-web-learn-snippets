case node['platform']
when 'centos' then
  package 'httpd'
  execute 'enable the httpd service' do
    command 'chkconfig httpd on --level 3'
    not_if 'chkconfig --list httpd | grep 3:on'
  end
  execute 'start the httpd service' do
    command 'service httpd start'
    not_if "service --status-all | grep -e 'httpd (pid\s*[0-9]*) is running'"
  end
when 'ubuntu' then
  package 'apache2'
  execute 'enable the apache2 service' do
    command 'update-rc.d apache2 defaults'
    not_if 'ls /etc/rc?.d/*apache2'
  end
  execute 'start the apache2 service' do
    command 'service apache2 start'
    not_if "service apache2 status | grep 'apache2 is running'"
  end
end

file '/var/www/html/index.html' do
  content '<html>
  <body>
    <h1>hello world</h1>
  </body>
</html>'
end
