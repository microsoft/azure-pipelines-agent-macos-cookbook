ruby_block 'service is up and running' do
  block do
    cmd = shell_out '/bin/launchctl', 'list', user: admin_user
    agents = cmd.stdout.lines.map { |line| line.split("\t").last.strip }
    raise Chef::Application.fatal!('VSTS agent service is not enabled!') unless agents.include? "vsts.agent.#{account_name}.#{agent_name}"
  end
end
