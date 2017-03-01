directory node['web_content']['document_root'] do
  rights :read, 'IIS_WPG'
  recursive true
  action :create
end
