directory node['web_content']['document_root'] do
  rights :read, node['web_content']['group']
  recursive true
  action :create
end
