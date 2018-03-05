vsts_agent_macos node['vsts_agent']['agent_name'] do
  action %i(install configure install_service start_service)
end
