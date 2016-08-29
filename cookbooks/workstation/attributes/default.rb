default['products']['versions'].tap do |product|
  product['virtualbox']['ubuntu'] = '5.0'
  product['virtualbox']['windows'] = '5.0.24.108355'

  product['vagrant']['ubuntu'] = '1.8.4'
  product['vagrant']['windows'] = '1.8.4'

  product['chefdk']['ubuntu'] = "stable-0.16.28"
  product['chefdk']['rhel'] = "stable-0.16.28"
  product['chefdk']['windows'] = "stable-0.16.28"
end

default['workstation']['environment']['windows'] = 'C:\opscode\chefdk\bin\;C:\opscode\chefdk\embedded\bin;C:\opscode\chefdk\embedded\git\usr\bin;C:\opscode\chef\bin\;C:\Users\vagrant\AppData\Local\chefdk\gem\ruby\2.1.0\bin;C:\ProgramData\chocolatey\bin;C:\HashiCorp\Vagrant\bin;C:\Program Files\Oracle\VirtualBox;C:\PROGRA~2\Oracle\VirtualBox;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;'
