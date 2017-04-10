apt_update 'daily' do
  frequency 86_400
  action :periodic
end

include_recipe 'lamp::web'
include_recipe 'lamp::database'
