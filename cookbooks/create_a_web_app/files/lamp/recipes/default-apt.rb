apt_update 'daily' do
  frequency 86_400
  action :periodic
end
