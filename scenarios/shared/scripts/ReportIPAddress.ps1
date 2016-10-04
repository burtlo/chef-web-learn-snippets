(Get-NetIPAddress -AddressState Preferred -PrefixOrigin Dhcp).IPAddress | Out-File -Encoding ASCII C:\vagrant\$($env:COMPUTERNAME.ToLower())-ipaddress.txt
