describe mysql_conf('/etc/mysql-default/my.cnf').params('mysqld') do
  its('port') { should eq '3306' }
  its('socket') { should eq '/run/mysql-default/mysqld.sock' }
end

describe port 3306 do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end

describe command("mysql -h 127.0.0.1 -uroot -pfakerootpassword -s -e 'show databases;'") do
  its('stdout') { should match(/mysql/) }
end
