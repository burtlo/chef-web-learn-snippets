describe command("mysql -h 127.0.0.1 -uroot -pfakerootpassword -D 4thcoffee -e 'describe customers;'") do
  its('stdout') { should match(/id/) }
end

describe command 'wget -qO- localhost' do
  its('stdout') { should match(/Customers/) }
end
