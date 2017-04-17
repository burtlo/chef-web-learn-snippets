# Install php5-mysql.
package 'php5-mysql' do
  action :install
  notifies :restart, 'httpd_service[default]'
end
