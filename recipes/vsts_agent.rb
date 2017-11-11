vsts_agent_macos node['vsts_agent']['agent_name'] do
  action %i(install configure)
end

# vsts_agent_macos node['vsts_agent']['agent_name'] do
#   action :remove
# end
