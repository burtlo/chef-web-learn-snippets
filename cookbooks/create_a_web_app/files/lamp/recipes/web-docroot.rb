# Create the document root directory.
directory node['lamp']['web']['document_root'] do
  recursive true
end
