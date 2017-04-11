mysql_connection_info = {
  host: '127.0.0.1',
  username: 'root',
  password: passwords['root_password']
}

# Create the database instance.
mysql_database node['lamp']['database']['dbname'] do
  connection mysql_connection_info
  action :create
end

# Add a database user.
mysql_database_user node['lamp']['database']['admin_username'] do
  connection mysql_connection_info
  password passwords['admin_password']
  database_name node['lamp']['database']['dbname']
  host '127.0.0.1'
  action [:create, :grant]
end
