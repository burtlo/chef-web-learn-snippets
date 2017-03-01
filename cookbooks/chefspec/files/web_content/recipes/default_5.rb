directory 'c:\inetpub\wwwroot' do
  rights :read, 'IIS_IUSRS'
  recursive true
  action :create
end
