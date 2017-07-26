$Stoploop = $false
[int]$Retrycount = "0"

do {
  try {
    $name = $env:COMPUTERNAME.ToLower()
    Write-Host "Computer name is $name"

    $ip_addr = (Get-NetIPAddress -AddressState Preferred -PrefixOrigin Dhcp).IPAddress
    Write-Host "IP address is $ip_addr"

    $ip_addr | Out-File -Encoding ASCII "C:\vagrant\$name-ipaddress.txt"
    $Stoploop = $true
    }
  catch {
    if ($Retrycount -gt 3){
      Write-Host "Could not obtain IP address after 3 retries."
      $Stoploop = $true
    }
    else {
      Write-Host "Could not obtain IP address - retrying in 10 seconds..."
      Start-Sleep -Seconds 10
      $Retrycount = $Retrycount + 1
    }
  }
}
While ($Stoploop -eq $false)
