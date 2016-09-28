execute 'Enable SSH access' do
  command 'ufw allow ssh'
  not_if 'ufw status | grep "22\s*ALLOW\s*Anywhere"'
end

execute 'Enable UFW' do
  command 'ufw --force enable'
  not_if 'ufw status | grep "^Status:\sactive"'
end
