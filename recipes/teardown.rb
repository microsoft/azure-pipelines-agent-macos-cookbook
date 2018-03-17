vsts_agent_macos agent_name do
  action [:stop_service,
          :uninstall_service,
          :remove]
end
