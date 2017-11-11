vsts_agent_macos node['vsts_agent']['agent_name'] do
  action %i(install configure setup_service)
end

# vsts_agent_macos node['vsts_agent']['agent_name'] do
#   action :remove
# end
