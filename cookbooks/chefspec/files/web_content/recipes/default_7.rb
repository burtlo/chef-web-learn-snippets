directory node['web_content']['document_root'] do
  rights :read, 'IIS_IUSRS'
  recursive true
  action :create
end
