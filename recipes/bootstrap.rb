vsts_agent_macos agent_name do
  action [:install,
          :configure,
          :install_service,
          :start_service]
end
