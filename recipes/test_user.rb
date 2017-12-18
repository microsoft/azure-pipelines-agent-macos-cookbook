include_recipe 'sudo'

macos_user 'admin' do
  autologin true
  admin true
end
