default['products']['versions'].tap do |product|
  product['virtualbox']['ubuntu'] = '5.1'
  product['virtualbox']['windows'] = '5.1.16'

  product['vagrant']['ubuntu'] = '1.9.4'
  product['vagrant']['windows'] = '1.9.4'

  product['packer']['ubuntu'] = '0.11.0'

  product['chefdk']['ubuntu'] = "stable-1.5.0"
  product['chefdk']['centos'] = "stable-1.5.0"
  product['chefdk']['windows'] = "stable-1.5.0"

  product['chef_server']['ubuntu'] = 'stable-12.15.8'
  product['compliance']['ubuntu'] = 'stable-1.10.2'
end

default['workstation']['environment']['windows'] = 'C:\opscode\chefdk\bin\;C:\opscode\chefdk\embedded\bin;C:\opscode\chefdk\embedded\git\usr\bin;C:\opscode\chef\bin\;C:\Users\vagrant\AppData\Local\chefdk\gem\ruby\2.1.0\bin;C:\ProgramData\chocolatey\bin;C:\HashiCorp\Vagrant\bin;C:\Program Files\Oracle\VirtualBox;C:\PROGRA~2\Oracle\VirtualBox;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;'
