registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft Services\AdmPwd' do
  values [{
    name: 'PasswordComplexity',
    type: :dword,
    data: 4
  }]
  action :create
  recursive true
end
