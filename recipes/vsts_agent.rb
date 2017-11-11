# vsts_agent_macos node['vsts_agent']['agent_name'] do
#   action %i(install configure setup_service)
# end

# vsts_agent_macos node['vsts_agent']['agent_name'] do
#   action :stop_service
# end

vsts_agent_macos node['vsts_agent']['agent_name'] do
  action %i(stop_service uninstall_service remove)
end
